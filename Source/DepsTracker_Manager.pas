unit DepsTracker_Manager;

{$INCLUDE '.\DepsTracker_defs.inc'}

interface

uses
  AuxClasses,
  DepsTracker_Common, DepsTracker_Project;

{===============================================================================
--------------------------------------------------------------------------------
                                   TDTManager
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDTManager - class declaration
===============================================================================}
type
  TDTManager = class(TCustomListObject)
  protected
    fProjects:      array of TDTProject;
    fProjectCount:  Integer;
    Function GetProject(Index: Integer): TDTProject; virtual;
    Function GetCapacity: Integer; override;
    procedure SetCapacity(Value: Integer); override;
    Function GetCount: Integer; override;
    procedure SetCount(Value: Integer); override;
    procedure Initialize; virtual;
    procedure Finalize; virtual;
    Function ProjectsCompare(A,B: TDTProject): Integer; overload; virtual;
    Function ProjectsCompare(A,B: Integer): Integer; overload; virtual;
    procedure ProjectsExchange(A,B: Integer); virtual;
    procedure ReIndex; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    Function LowIndex: Integer; override;
    Function HighIndex: Integer; override;
    Function IndexOf(Project: TDTProject): Integer; overload; virtual;
    Function IndexOf(const ProjectName: String): Integer; overload; virtual;
    Function Find(Project: TDTProject; out Index: Integer): Boolean; overload; virtual;
    Function Find(const ProjectName: String; out Index: Integer): Boolean; overload; virtual;
    Function Add(Project: TDTProject): Integer; overload; virtual;
    Function Add(const ProjectName: String): Integer; overload; virtual;
    Function Remove(Project: TDTProject): Integer; virtual;
    procedure Delete(Index: Integer); virtual;
    procedure Clear; virtual;
    procedure Sort; virtual;
    procedure SaveToFile(const FileName: String); virtual;
    procedure LoadFromFile(const FileName: String); virtual;
    property Projects[Index: Integer]: TDTProject read GetProject; default;
  end;

implementation

uses
  AuxTypes, Classes,
  StrRect, ListSorters, BinaryStreamingLite;

{===============================================================================
--------------------------------------------------------------------------------
                                   TDTManager
--------------------------------------------------------------------------------
===============================================================================}
const
  DT_FILE_SIGNATURE = UInt32($0105090D);
  DT_FILE_VERSION_0 = UInt32(0);

{===============================================================================
    TDTManager - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TDTManager - protected methods
-------------------------------------------------------------------------------}

Function TDTManager.GetProject(Index: Integer): TDTProject;
begin
If CheckIndex(Index) then
  Result := fProjects[Index]
else
  raise EDTIndexOutOfBounds.CreateFmt('TDTManager.GetProject: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

Function TDTManager.GetCapacity: Integer;
begin
Result := Length(fProjects);
end;

//------------------------------------------------------------------------------

procedure TDTManager.SetCapacity(Value: Integer);
begin
If Value >= 0 then
  begin
    If Value < fProjectCount then
      raise EDTInvalidValue.CreateFmt('TDTManager.SetCapacity: New capacity capacity (%d) is lower than count.',[Value]);
    SetLength(fProjects,Value);
  end
else raise EDTInvalidValue.CreateFmt('TDTManager.SetCapacity: Invalid capacity value (%d).',[Value]);
end;

//------------------------------------------------------------------------------

Function TDTManager.GetCount: Integer;
begin
Result := fProjectCount;
end;

//------------------------------------------------------------------------------

procedure TDTManager.SetCount(Value: Integer);
begin
// do nothing
end;

//------------------------------------------------------------------------------

procedure TDTManager.Initialize;
begin
fProjects := nil;
fProjectCount := 0;
end;

//------------------------------------------------------------------------------

procedure TDTManager.Finalize;
begin
Clear;
end;

//------------------------------------------------------------------------------

Function TDTManager.ProjectsCompare(A,B: TDTProject): Integer;
begin
If A <> B then
  begin
    If A.ProjectType <> B.ProjectType then
      Result := Ord(A.ProjectType) - Ord(B.ProjectType)
    else
      Result := StringCompare(A.Name,B.Name,False);
  end
else Result := 0;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TDTManager.ProjectsCompare(A,B: Integer): Integer;
begin
If A <> B then
  Result := ProjectsCompare(fProjects[A],fProjects[B])
else
  Result := 0;
end;

//------------------------------------------------------------------------------

procedure TDTManager.ProjectsExchange(A,B: Integer);
var
  Temp: TDTPRoject;
begin
If A <> B then
  begin
    Temp := fProjects[A];
    fProjects[A] := fProjects[B];
    fProjects[B] := Temp;
  end;
end;

//------------------------------------------------------------------------------

procedure TDTManager.ReIndex;
var
  i:  Integer;
begin
For i := LowIndex to HighIndex do
  fProjects[i].Index := i;
end;

{-------------------------------------------------------------------------------
    TDTManager - public methods
-------------------------------------------------------------------------------}

constructor TDTManager.Create;
begin
inherited;
Initialize;
end;

//------------------------------------------------------------------------------

destructor TDTManager.Destroy;
begin
Finalize;
inherited;
end;

//------------------------------------------------------------------------------

Function TDTManager.LowIndex: Integer;
begin
Result := Low(fProjects);
end;

//------------------------------------------------------------------------------

Function TDTManager.HighIndex: Integer;
begin
Result := Pred(fProjectCount);
end;

//------------------------------------------------------------------------------

Function TDTManager.IndexOf(Project: TDTProject): Integer;
var
  i:  Integer;
begin
Result := -1;
For i := LowIndex to HighIndex do
  If fProjects[i] = Project then
    begin
      Result := i;
      Break{For i};
    end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TDTManager.IndexOf(const ProjectName: String): Integer;
var
  i:  Integer;
begin
Result := -1;
For i := LowIndex to HighIndex do
  If StringCompare(fProjects[i].Name,ProjectName,False) = 0 then
    begin
      Result := i;
      Break{For i};
    end;
end;

//------------------------------------------------------------------------------

Function TDTManager.Find(Project: TDTProject; out Index: Integer): Boolean;
begin
Index := IndexOf(Project);
Result := CheckIndex(Index);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TDTManager.Find(const ProjectName: String; out Index: Integer): Boolean;
begin
Index := IndexOf(ProjectName);
Result := CheckIndex(Index);
end;

//------------------------------------------------------------------------------

Function TDTManager.Add(Project: TDTProject): Integer;
var
  i:  Integer;
begin
If not Find(Project.Name,Result) then
  begin
    Grow;  
    // sorted addition
    Result := 0;
    For i := LowIndex to HighIndex do
      begin
        If ProjectsCompare(fProjects[i],Project) > 0 then
          Break{For i};
        Inc(Result);
      end;
    For i := HighIndex downto Result do
      fProjects[i + 1] := fProjects[i];
    fProjects[Result] := Project;
    Inc(fProjectCount);
    ReIndex;
  end
else raise EDTDuplicateError.CreateFmt('TDTManager.Add: Project of this name already exists ("%s").',[Project.Name]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TDTManager.Add(const ProjectName: String): Integer;
begin
If not Find(ProjectName,Result) then
  Result := Add(TDTProject.Create(ProjectName))
else
  raise EDTDuplicateError.CreateFmt('TDTManager.Add: Project of this name already exists ("%s").',[ProjectName]);
end;

//------------------------------------------------------------------------------

Function TDTManager.Remove(Project: TDTProject): Integer;
begin
If Find(Project,Result) then
  Delete(Result);
end;

//------------------------------------------------------------------------------

procedure TDTManager.Delete(Index: Integer);
var
  i:  Integer;
begin
If CheckIndex(Index) then
  begin
    For i := LowIndex to HighIndex do
      fProjects[i].DependenciesRemove(fProjects[Index]);
    fProjects[Index].DependenciesClear;
    fProjects[Index].Free;
    For i := Index to Pred(HighIndex) do
      fProjects[i] := fProjects[i + 1];
    fProjects[HighIndex] := nil;
    Dec(fProjectCount);
    Shrink;
    ReIndex;
  end
else raise EDTIndexOutOfBounds.CreateFmt('TDTManager.Delete: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

procedure TDTManager.Clear;
var
  i:  Integer;
begin
For i := LowIndex to HighIndex do
  fProjects[i].Free;
SetLength(fProjects,0);
fProjectCount := 0;
end;

//------------------------------------------------------------------------------

procedure TDTManager.Sort;
var
  Sorter: TListSorter;
begin
Sorter := TListQuickSorter.Create(ProjectsCompare,ProjectsExchange);
try
  Sorter.Sort(LowIndex,HighIndex);
finally
  Sorter.Free;
end;
ReIndex;
end;

//------------------------------------------------------------------------------

procedure TDTManager.SaveToFile(const FileName: String);
var
  Stream: TMemoryStream;
  i,j:    Integer;
begin
ReIndex;  // just to be sure
Stream := TMemoryStream.Create;
try
  Stream.Seek(0,soBeginning);
  Stream_WriteUInt32(Stream,DT_FILE_SIGNATURE);
  Stream_WriteUInt32(Stream,DT_FILE_VERSION_0);
  Stream_WriteInt32(Stream,fProjectCount);
  // save projects
  For i := LowIndex to HighIndex do
    fProjects[i].SaveToStream(Stream);
  // save dependency lists (indices)
  For i := LowIndex to HighIndex do
    begin
      Stream_WriteInt32(Stream,fProjects[i].DependenciesCount);
      For j := fProjects[i].DependenciesLowIndex to fProjects[i].DependenciesHighIndex do
        begin
          Stream_WriteInt32(Stream,fProjects[i][j].Index);
          Stream_WriteBoolean(Stream,fProjects[i].DependenciesInfo[j].Conditional);
          Stream_WriteString(Stream,fProjects[i].DependenciesInfo[j].ConditionNotes);
        end;
    end;
  Stream.SaveToFile(StrToRTL(FileName));
finally
  Stream.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TDTManager.LoadFromFile(const FileName: String);
var
  Stream: TMemoryStream;
  i,j:    Integer;
  Idx:    Integer;
begin
Clear;
Stream := TMemoryStream.Create;
try
  Stream.LoadFromFile(StrToRTL(FileName));
  Stream.Seek(0,soBeginning);
  If Stream_GetUint32(Stream) <> DT_FILE_SIGNATURE then
    raise EDTInvalidFile.Create('TDTManager.LoadFromFile: Invalid file signature.');
  If Stream_GetUint32(Stream) <> DT_FILE_VERSION_0 then
    raise EDTInvalidFile.Create('TDTManager.LoadFromFile: Invalid file version.');
  // load projects
  fProjectCount := Stream_GetInt32(Stream);
  SetCapacity(fProjectCount);
  For i := LowIndex to HighIndex do
    begin
      fProjects[i] := TDTProject.Create(Stream);
      // lock all projects to prevent update storm when loading dependencies
      fProjects[i].BeginInterlockedOperations;
    end;
  ReIndex;  
  try
    // load dependecies for projects
    For i := LowIndex to HighIndex do
      For j := 0 to Pred(Stream_GetInt32(Stream)) do
        begin
          Idx := fProjects[i].DependenciesAdd(GetProject(Stream_GetInt32(Stream)));
          fProjects[i].DependenciesInfoPtr[Idx]^.Conditional := Stream_GetBoolean(Stream);
          fProjects[i].DependenciesInfoPtr[Idx]^.ConditionNotes := Stream_GetString(Stream);
        end;
  finally
    For i := LowIndex to HighIndex do
      fProjects[i].EndInterlockedOperations;
  end;
  // resolve indirect dependencies and dependents
  For i := LowIndex to HighIndex do
    begin
      fProjects[i].EnumerateIndirectDependencies;
      fProjects[i].EnumerateIndirectDependents;
    end;
finally
  Stream.Free;
end;
end;

end.
