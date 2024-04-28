{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit DepsTracker_Project;

{$INCLUDE '.\DepsTracker_defs.inc'}

interface

uses
  Classes,
  AuxClasses,
  DepsTracker_Common;

{===============================================================================
--------------------------------------------------------------------------------
                                   TDTProject
--------------------------------------------------------------------------------
===============================================================================}
const
  DT_PROJLIST_DEPENDENCIES       = 0;
  DT_PROJLIST_DEPENDENTS         = 1;
  DT_PROJLIST_INDIR_DEPENDENCIES = 2;
  DT_PROJLIST_INDIR_DEPENDENTS   = 3;

type
  TDTInterlockedOperation = (iopDepsEnum,iopDpdsEnum,iopTreeEnum);

  TDTInterlockedOperations = set of TDTInterlockedOperation;

const
  DT_INTERLOCKOPS_ALL = [iopDepsEnum,iopDpdsEnum];

type
  TDTDependencyInfo = record
    BoundObject:    TObject;  // must be TDTProject
    Conditional:    Boolean;
    ConditionNotes: String;
    IsAlsoIndirect: Boolean;
  end;
  PDTDependencyInfo = ^TDTDependencyInfo;

{===============================================================================
    TDTProject - class declaration
===============================================================================}
type
  TDTProject = class(TCustomMultiListObject)
  protected
    fIndex:                   Integer;
    fName:                    String;
    fProjectType:             TDTProjectType;
    fRepositoryURL:           String;
    fProjectDir:              String;
    fNotes:                   String;
    fFlagged:                 Boolean;
    // lists
    fDependencies:            array of TDTDependencyInfo;
    fDependenciesCount:       Integer;
    fDependents:              array of TDTProject;
    fDependentsCount:         Integer;
    fIndirDependencies:       array of TDTProject;
    fIndirDependenciesCount:  Integer;
    fIndirDependents:         array of TDTProject;
    fIndirDependentsCount:    Integer;
    fInterlockedOpsFlags:     TDTInterlockedOperations;
    // getters, setters
    procedure SetName(const Value: String); virtual;
    Function GetDependencyInfoPtr(Index: Integer): PDTDependencyInfo; virtual;
    Function GetDependencyInfo(Index: Integer): TDTDependencyInfo; virtual;
    Function GetDependency(Index: Integer): TDTProject; virtual;
    Function GetDependent(Index: Integer): TDTProject; virtual;
    Function GetIndirectDependency(Index: Integer): TDTProject; virtual;
    Function GetIndirectDependent(Index: Integer): TDTProject; virtual;
    // inherited list management
    Function GetCapacity(List: Integer): Integer; override;
    procedure SetCapacity(List,Value: Integer); override;
    Function GetCount(List: Integer): Integer; override;
    procedure SetCount(List,Value: Integer); override;
    // dependents list
    Function DependentsIndexOf(Dependent: TDTProject): Integer; virtual;
    Function DependentsFind(Dependent: TDTProject; out Index: Integer): Boolean; virtual;
    Function DependentsAdd(Dependent: TDTProject): Integer; virtual;
    Function DependentsRemove(Dependent: TDTProject): Integer; virtual;
    // sorting routines
    Function DependenciesCompare(A,B: Integer): Integer; virtual;
    procedure DependenciesExchange(A,B: Integer); virtual;
    procedure DependenciesSort; virtual;
    Function DependentsCompare(A,B: Integer): Integer; virtual;
    procedure DependentsExchange(A,B: Integer); virtual;
    procedure DependentsSort; virtual;
    Function IndirectDependenciesCompare(A,B: Integer): Integer; virtual;
    procedure IndirectDependenciesExchange(A,B: Integer); virtual;
    procedure IndirectDependenciesSort; virtual;
    Function IndirectDependentsCompare(A,B: Integer): Integer; virtual;
    procedure IndirectDependentsExchange(A,B: Integer); virtual;
    procedure IndirectDependentsSort; virtual;
    // enumerations, traversals
    procedure EnumerateDependencies(Vector: TObject); virtual;
    procedure EnumerateDependents(Vector: TObject); virtual;
    procedure EnumerateTree(Node: Pointer); virtual;
    // object init/final
    procedure Initialize(const Name: String); virtual;
    procedure Finalize; virtual;
    procedure LoadFromStream(Stream: TStream); virtual;    
  public
    constructor Create(const Name: String); overload;
    constructor Create(Stream: TStream); overload;
    destructor Destroy; override;
    // interlocked operations
    procedure BeginInterlockedOperations; virtual;
    procedure EndInterlockedOperations; virtual;
    Function BeginInterlockedOperation(Operation: TDTInterlockedOperation): Boolean; virtual;
    procedure EndInterlockedOperation(Operation: TDTInterlockedOperation); virtual;
    // list indices
    Function LowIndex(List: Integer): Integer; override;
    Function HighIndex(List: Integer): Integer; override;
    Function DependenciesLowIndex: Integer; virtual;
    Function DependenciesHighIndex: Integer; virtual;
    Function DependenciesCheckIndex(Index: Integer): Boolean; virtual;
    Function DependentsLowIndex: Integer; virtual;
    Function DependentsHighIndex: Integer; virtual;
    Function DependentsCheckIndex(Index: Integer): Boolean; virtual;
    Function IndirectDependenciesLowIndex: Integer; virtual;
    Function IndirectDependenciesHighIndex: Integer; virtual;
    Function IndirectDependenciesCheckIndex(Index: Integer): Boolean; virtual;
    Function IndirectDependentsLowIndex: Integer; virtual;
    Function IndirectDependentsHighIndex: Integer; virtual;
    Function IndirectDependentsCheckIndex(Index: Integer): Boolean; virtual;
    // dependencies list
    Function DependenciesIndexOf(Dependency: TDTProject): Integer; virtual;
    Function DependenciesFind(Dependency: TDTProject; out Index: Integer): Boolean; virtual;
    Function DependenciesAdd(Dependency: TDTProject): Integer; virtual;
    Function DependenciesRemove(Dependency: TDTProject): Integer; virtual;
    procedure DependenciesDelete(Index: Integer); virtual;
    procedure DependenciesClear; virtual;
    // indirect lists
    Function IndirectDependenciesFind(Dependency: TDTProject; out Index: Integer): Boolean; virtual;
    procedure EnumerateIndirectDependencies; virtual;
    procedure EnumerateIndirectDependents; virtual;
    // utility
    Function FullName: String; virtual;
    // I/O
    procedure SaveToStream(Stream: TStream); virtual;
    // reports
    Function CreateDependencyReport: TStrings; virtual;
    Function CreateDependencyTree: TStrings; virtual;
    // properties
    property Index: Integer read fIndex write fIndex;
    property Name: String read fName write SetName;
    property ProjectType: TDTProjectType read fProjectType write fProjectType;
    property RepositoryURL: String read fRepositoryURL write fRepositoryURL;
    property ProjectDirector: String read fProjectDir write fProjectDir;
    property Notes: String read fNotes write fNotes;
    property Flagged: Boolean read fFlagged write fFlagged;
    property DependenciesCount: Integer index DT_PROJLIST_DEPENDENCIES read GetCount;
    property DependenciesInfoPtr[Index: Integer]: PDTDependencyInfo read GetDependencyInfoPtr;
    property DependenciesInfo[Index: Integer]: TDTDependencyInfo read GetDependencyInfo; 
    property Dependencies[Index: Integer]: TDTProject read GetDependency; default;
    property DependentsCount: Integer index DT_PROJLIST_DEPENDENTS read GetCount;
    property Dependents[Index: Integer]: TDTProject read GetDependent;
    property IndirectDependenciesCount: Integer index DT_PROJLIST_INDIR_DEPENDENCIES read GetCount;
    property IndirectDependencies[Index: Integer]: TDTProject read GetIndirectDependency;
    property IndirectDependentsCount: Integer index DT_PROJLIST_INDIR_DEPENDENTS read GetCount;
    property IndirectDependents[Index: Integer]: TDTProject read GetIndirectDependent;
  end;

type
  TDTProjectEvent = procedure(Sender: TObject; Project: TDTProject) of object;

  TDTProjectArray = array of TDTProject;

implementation

uses
  SysUtils,
  StrRect, ListSorters, BinaryStreamingLite, MemVector, AuxMath;

{===============================================================================
--------------------------------------------------------------------------------
                               TDTAuxProjectVector
--------------------------------------------------------------------------------
===============================================================================}
{===============================================================================
    TDTAuxProjectVector - class declaration
===============================================================================}
type
  TDTAuxProjectVector = class(TMemVector)
  protected
    Function GetItem(Index: Integer): TDTProject; virtual;
    procedure SetItem(Index: Integer; Value: TDTProject); virtual;
    Function ItemCompare(Item1,Item2: Pointer): Integer; override;
  public
    constructor Create; overload;
    constructor Create(Memory: Pointer; Count: Integer); overload;
    Function First: TDTProject; reintroduce;
    Function Last: TDTProject; reintroduce;
    Function IndexOf(Item: TDTProject): Integer; reintroduce;
    Function Find(Item: TDTProject; out Index: Integer): Boolean; virtual;
    Function Add(Item: TDTProject): Integer; reintroduce;
    procedure Insert(Index: Integer; Item: TDTProject); reintroduce;
    Function Remove(Item: TDTProject): Integer; reintroduce;
    Function Extract(Item: TDTProject): TDTProject; reintroduce;
    property Items[Index: Integer]: TDTProject read GetItem write SetItem; default;
  end;

{===============================================================================
    TDTAuxProjectVector - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TDTAuxProjectVector - protected methods
-------------------------------------------------------------------------------}

Function TDTAuxProjectVector.GetItem(Index: Integer): TDTProject;
begin
Result := TDTProject(GetItemPtr(Index)^);
end;

//------------------------------------------------------------------------------

procedure TDTAuxProjectVector.SetItem(Index: Integer; Value: TDTProject);
begin
SetItemPtr(Index,@Value);
end;

//------------------------------------------------------------------------------

Function TDTAuxProjectVector.ItemCompare(Item1,Item2: Pointer): Integer;
begin
Result := StringCompare(TDTProject(Item1^).Name,TDTProject(Item2^).Name,False);
end;

{-------------------------------------------------------------------------------
    TDTAuxProjectVector - public methods
-------------------------------------------------------------------------------}

constructor TDTAuxProjectVector.Create;
begin
inherited Create(SizeOf(TDTProject));
end;

//   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---

constructor TDTAuxProjectVector.Create(Memory: Pointer; Count: Integer);
begin
inherited Create(Memory,Count,SizeOf(TDTProject));
end;

//------------------------------------------------------------------------------

Function TDTAuxProjectVector.First: TDTProject;
begin
Result := TDTProject(inherited First^);
end;

//------------------------------------------------------------------------------

Function TDTAuxProjectVector.Last: TDTProject;
begin
Result := TDTProject(inherited Last^);
end;

//------------------------------------------------------------------------------

Function TDTAuxProjectVector.IndexOf(Item: TDTProject): Integer;
begin
Result := inherited IndexOf(@Item);
end;

//------------------------------------------------------------------------------

Function TDTAuxProjectVector.Find(Item: TDTProject; out Index: Integer): Boolean;
begin
Index := IndexOf(Item);
Result := CheckIndex(Index);
end;

//------------------------------------------------------------------------------

Function TDTAuxProjectVector.Add(Item: TDTProject): Integer;
begin
Result := inherited Add(@Item);
end;
  
//------------------------------------------------------------------------------

procedure TDTAuxProjectVector.Insert(Index: Integer; Item: TDTProject);
begin
inherited Insert(Index,@Item);
end;
 
//------------------------------------------------------------------------------

Function TDTAuxProjectVector.Remove(Item: TDTProject): Integer;
begin
Result := inherited Remove(@Item);
end;
 
//------------------------------------------------------------------------------

Function TDTAuxProjectVector.Extract(Item: TDTProject): TDTProject;
var
  TempPtr:  Pointer;
begin
TempPtr := inherited Extract(@Item);
If Assigned(TempPtr) then
  Result := TDTProject(TempPtr^)
else
  Result := nil;
end;



{===============================================================================
--------------------------------------------------------------------------------
                                   TDTProject
--------------------------------------------------------------------------------
===============================================================================}
type
  PDTTreeNode = ^TDTTreeNode;
  TDTTreeNode = record
    ParentNode:         PDTTreeNode;
    Project:            TDTPRoject;
    Conditional:        Boolean;
    Repeating:          Boolean;
    SubNodes:           array of PDTTreeNode;
    LeafsOnly:          Boolean;
    UnconditionalOnly:  Boolean;
    CompactSubTree:     Boolean;
    StringBuilding:     record
      NodePath:           String;
      NextPath:           String;
    end;
  end;
  
{===============================================================================
    TDTProject - class implementation
===============================================================================}
{-------------------------------------------------------------------------------
    TDTProject - protected methods
-------------------------------------------------------------------------------}

procedure TDTProject.SetName(const Value: String);
var
  i:  Integer;
begin
If StringCompare(fName,Value,True) <> 0 then
  begin
    fName := Value;
    // sort in dependencies
    For i := DependenciesLowIndex to DependenciesHighIndex do
      (fDependencies[i].BoundObject as TDTProject).DependentsSort;
    For i := IndirectDependenciesLowIndex to IndirectDependenciesHighIndex do
      fIndirDependencies[i].IndirectDependentsSort;
    // sort in dependents
    For i := DependentsLowIndex to DependentsHighIndex do
      fDependents[i].DependenciesSort;
    For i := IndirectDependentsLowIndex to IndirectDependentsHighIndex do
      fIndirDependents[i].IndirectDependenciesSort;
  end;
end;

//------------------------------------------------------------------------------

Function TDTProject.GetDependencyInfoPtr(Index: Integer): PDTDependencyInfo;
begin
If DependenciesCheckIndex(Index) then
  Result := Addr(fDependencies[Index])
else
  raise EDTIndexOutOfBounds.CreateFmt('TDTProject.GetDependencyInfoPtr: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

Function TDTProject.GetDependencyInfo(Index: Integer): TDTDependencyInfo;
begin
If DependenciesCheckIndex(Index) then
  Result := fDependencies[Index]
else
  raise EDTIndexOutOfBounds.CreateFmt('TDTProject.GetDependencyInfo: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

Function TDTProject.GetDependency(Index: Integer): TDTProject;
begin
If DependenciesCheckIndex(Index) then
  Result := fDependencies[Index].BoundObject as TDTProject
else
  raise EDTIndexOutOfBounds.CreateFmt('TDTProject.GetDependency: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

Function TDTProject.GetDependent(Index: Integer): TDTProject;
begin
If DependentsCheckIndex(Index) then
  Result := fDependents[Index]
else
  raise EDTIndexOutOfBounds.CreateFmt('TDTProject.GetDependent: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

Function TDTProject.GetIndirectDependency(Index: Integer): TDTProject;
begin
If IndirectDependenciesCheckIndex(Index) then
  Result := fIndirDependencies[Index]
else
  raise EDTIndexOutOfBounds.CreateFmt('TDTProject.GetIndirectDependency: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

Function TDTProject.GetIndirectDependent(Index: Integer): TDTProject;
begin
If IndirectDependentsCheckIndex(Index) then
  Result := fIndirDependents[Index]
else
  raise EDTIndexOutOfBounds.CreateFmt('TDTProject.GetIndirectDependent: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

Function TDTProject.GetCapacity(List: Integer): Integer;
begin
case List of
  DT_PROJLIST_DEPENDENCIES:       Result := Length(fDependencies);
  DT_PROJLIST_DEPENDENTS:         Result := Length(fDependents);
  DT_PROJLIST_INDIR_DEPENDENCIES: Result := Length(fIndirDependencies);
  DT_PROJLIST_INDIR_DEPENDENTS:   Result := Length(fIndirDependents);
else
  raise EDTInvalidValue.CreateFmt('TDTProject.GetCapacity: Invalid list (%d).',[List]);
end;
end;

//------------------------------------------------------------------------------

procedure TDTProject.SetCapacity(List,Value: Integer);
begin
If Value >= 0 then
  case List of
    DT_PROJLIST_DEPENDENCIES:
      begin
        If Value < fDependenciesCount then
          raise EDTInvalidValue.CreateFmt('TDTProject.SetCapacity: New dependencies capacity (%d) is lower than count.',[Value]);
        SetLength(fDependencies,Value);
      end;
    DT_PROJLIST_DEPENDENTS:
      begin
        If Value < fDependentsCount then
          raise EDTInvalidValue.CreateFmt('TDTProject.SetCapacity: New dependents capacity (%d) is lower than count.',[Value]);
        SetLength(fDependents,Value);
      end;
    DT_PROJLIST_INDIR_DEPENDENCIES:
      begin
        If Value < fIndirDependenciesCount then
          raise EDTInvalidValue.CreateFmt('TDTProject.SetCapacity: New indirect dependencies capacity (%d) is lower than count.',[Value]);
        SetLength(fIndirDependencies,Value);
      end;
    DT_PROJLIST_INDIR_DEPENDENTS:
      begin
        If Value < fIndirDependentsCount then
          raise EDTInvalidValue.CreateFmt('TDTProject.SetCapacity: New indirect dependents capacity (%d) is lower than count.',[Value]);
        SetLength(fIndirDependents,Value);
      end;
  else
    raise EDTInvalidValue.CreateFmt('TDTProject.SetCapacity: Invalid list (%d).',[List]);
  end
else raise EDTInvalidValue.CreateFmt('TDTProject.SetCapacity: Invalid capacity value (%d).',[Value]);
end;

//------------------------------------------------------------------------------

Function TDTProject.GetCount(List: Integer): Integer;
begin
case List of
  DT_PROJLIST_DEPENDENCIES:       Result := fDependenciesCount;
  DT_PROJLIST_DEPENDENTS:         Result := fDependentsCount;
  DT_PROJLIST_INDIR_DEPENDENCIES: Result := fIndirDependenciesCount;
  DT_PROJLIST_INDIR_DEPENDENTS:   Result := fIndirDependentsCount;
else
  raise EDTInvalidValue.CreateFmt('TDTProject.GetCount: Invalid list (%d).',[List]);
end;
end;

//------------------------------------------------------------------------------

procedure TDTProject.SetCount(List,Value: Integer);
begin
// do nothing
end;

//------------------------------------------------------------------------------

Function TDTProject.DependentsIndexOf(Dependent: TDTProject): Integer;
var
  i:  Integer;
begin
Result := -1;
For i := DependentsLowIndex to DependentsHighIndex do
  If fDependents[i] = Dependent then
    begin
      Result := i;
      Break{For i};
    end;
end;

//------------------------------------------------------------------------------

Function TDTProject.DependentsFind(Dependent: TDTProject; out Index: Integer): Boolean;
begin
Index := DependentsIndexOf(Dependent);
Result := DependentsCheckIndex(Index);
end;

//------------------------------------------------------------------------------

Function TDTProject.DependentsAdd(Dependent: TDTProject): Integer;
var
  i:  Integer;
begin
If not DependentsFind(Dependent,Result) then
  begin
    Grow(DT_PROJLIST_DEPENDENTS);
    // sorted addition... get insertion index
    Result := DependentsLowIndex;
    while Result <= DependentsHighIndex do
      begin
        If StringCompare(fDependents[Result].Name,Dependent.Name,False) > 0 then
          Break{while};
        Inc(Result);
      end;
    For i := DependentsHighIndex downto Result do
      fDependents[i + 1] := fDependents[i];
    fDependents[Result] := Dependent;
    Inc(fDependentsCount);
  end;
end;

//------------------------------------------------------------------------------

Function TDTProject.DependentsRemove(Dependent: TDTProject): Integer;
var
  i:  Integer;
begin
// DO NOT remove self from dependencies of dependent
If DependentsFind(Dependent,Result) then
  begin
    For i := Result to Pred(DependentsHighIndex) do
      fDependents[i] := fDependents[i + 1];
    fDependents[DependentsHighIndex] := nil;
    Dec(fDependentsCount);
    Shrink(DT_PROJLIST_DEPENDENTS);
  end;
end;

//------------------------------------------------------------------------------

Function TDTProject.DependenciesCompare(A,B: Integer): Integer;
begin
Result := StringCompare(
  (fDependencies[A].BoundObject as TDTProject).Name,
  (fDependencies[B].BoundObject as TDTProject).Name,False);
end;

//------------------------------------------------------------------------------

procedure TDTProject.DependenciesExchange(A,B: Integer);
var
  TempEntry:  TDTDependencyInfo;
begin
If A <> B then
  begin
    TempEntry := fDependencies[A];
    fDependencies[A] := fDependencies[B];
    fDependencies[B] := TempEntry
  end;
end;

//------------------------------------------------------------------------------

procedure TDTProject.DependenciesSort;
begin
with TListQuickSorter.Create(DependenciesCompare,DependenciesExchange) do
try
  Sort(DependenciesLowIndex,DependenciesHighIndex);
finally
  Free;
end;
end;

//------------------------------------------------------------------------------

Function TDTProject.DependentsCompare(A,B: Integer): Integer;
begin
Result := StringCompare(fDependents[A].Name,fDependents[B].Name,False);
end;

//------------------------------------------------------------------------------

procedure TDTProject.DependentsExchange(A,B: Integer);
var
  TempEntry:  TDTProject;
begin
If A <> B then
  begin
    TempEntry := fDependents[A];
    fDependents[A] := fDependents[B];
    fDependents[B] := TempEntry
  end;
end;

//------------------------------------------------------------------------------

procedure TDTProject.DependentsSort;
begin
with TListQuickSorter.Create(DependentsCompare,DependentsExchange) do
try
  Sort(DependentsLowIndex,DependentsHighIndex);
finally
  Free;
end;
end;

//------------------------------------------------------------------------------

Function TDTProject.IndirectDependenciesCompare(A,B: Integer): Integer;
begin
Result := StringCompare(fIndirDependencies[A].Name,fIndirDependencies[B].Name,False);
end;

//------------------------------------------------------------------------------

procedure TDTProject.IndirectDependenciesExchange(A,B: Integer);
var
  TempEntry:  TDTProject;
begin
If A <> B then
  begin
    TempEntry := fIndirDependencies[A];
    fIndirDependencies[A] := fIndirDependencies[B];
    fIndirDependencies[B] := TempEntry
  end;
end;

//------------------------------------------------------------------------------

procedure TDTProject.IndirectDependenciesSort;
begin
with TListQuickSorter.Create(IndirectDependenciesCompare,IndirectDependenciesExchange) do
try
  Sort(IndirectDependenciesLowIndex,IndirectDependenciesHighIndex);
finally
  Free;
end;
end;

//------------------------------------------------------------------------------

Function TDTProject.IndirectDependentsCompare(A,B: Integer): Integer;
begin
Result := StringCompare(fIndirDependents[A].Name,fIndirDependents[B].Name,False);
end;

//------------------------------------------------------------------------------

procedure TDTProject.IndirectDependentsExchange(A,B: Integer);
var
  TempEntry:  TDTProject;
begin
If A <> B then
  begin
    TempEntry := fIndirDependents[A];
    fIndirDependents[A] := fIndirDependents[B];
    fIndirDependents[B] := TempEntry
  end;
end;

//------------------------------------------------------------------------------

procedure TDTProject.IndirectDependentsSort;
begin
with TListQuickSorter.Create(IndirectDependentsCompare,IndirectDependentsExchange) do
try
  Sort(IndirectDependentsLowIndex,IndirectDependentsHighIndex);
finally
  Free;
end;
end;

//------------------------------------------------------------------------------

procedure TDTProject.EnumerateDependencies(Vector: TObject);
var
  i,Idx:  Integer;
begin
If BeginInterlockedOperation(iopDepsEnum) then
try
  For i := DependenciesLowIndex to DependenciesHighIndex do
    begin
      If not (Vector as TDTAuxProjectVector).Find(fDependencies[i].BoundObject as TDTProject,Idx) then
        (Vector as TDTAuxProjectVector).Add(fDependencies[i].BoundObject as TDTProject);
      // recursive traversal...
      (fDependencies[i].BoundObject as TDTProject).EnumerateDependencies(Vector);
    end;
finally
  EndInterlockedOperation(iopDepsEnum);
end;
end;

//------------------------------------------------------------------------------

procedure TDTProject.EnumerateDependents(Vector: TObject);
var
  i,Idx:  Integer;
begin
If BeginInterlockedOperation(iopDpdsEnum) then
try
  For i := DependentsLowIndex to DependentsHighIndex do
    begin
      If not (Vector as TDTAuxProjectVector).Find(fDependents[i],Idx) then
        (Vector as TDTAuxProjectVector).Add(fDependents[i]);
      fDependents[i].EnumerateDependents(Vector);
    end; 
finally
  EndInterlockedOperation(iopDpdsEnum);
end;
end;

//------------------------------------------------------------------------------

procedure TDTProject.EnumerateTree(Node: Pointer);
var
  i:  Integer;
begin
PDTTreeNode(Node)^.Project := Self;
PDTTreeNode(Node)^.Conditional := False;
PDTTreeNode(Node)^.Repeating := False;
PDTTreeNode(Node)^.SubNodes := nil;
PDTTreeNode(Node)^.LeafsOnly := True;
PDTTreeNode(Node)^.UnconditionalOnly := True;
If BeginInterlockedOperation(iopTreeEnum) then
  try
    SetLength(PDTTreeNode(Node)^.SubNodes,DependenciesCount);
    For i := DependenciesLowIndex to DependenciesHighIndex do
      begin
        New(PDTTreeNode(Node)^.SubNodes[i]);
        PDTTreeNode(Node)^.SubNodes[i]^.ParentNode := Node;
        Dependencies[i].EnumerateTree(PDTTreeNode(Node)^.SubNodes[i]);
        PDTTreeNode(Node)^.SubNodes[i]^.Conditional := fDependencies[i].Conditional;
        If Length(PDTTreeNode(Node)^.SubNodes[i]^.SubNodes) > 0 then
          PDTTreeNode(Node)^.LeafsOnly := False;
        If PDTTreeNode(Node)^.SubNodes[i]^.Conditional then
          PDTTreeNode(Node)^.UnconditionalOnly := False;
      end;
  finally
    EndInterlockedOperation(iopTreeEnum);
  end
else
  begin
    PDTTreeNode(Node)^.Repeating := True;
    PDTTreeNode(Node)^.SubNodes := nil;
  end;
end;

//------------------------------------------------------------------------------

procedure TDTProject.Initialize(const Name: String);
begin
fIndex := -1;
fName := Name;
fProjectType := ptOthers;
fRepositoryURL := '';
fProjectDir := '';
fNotes := '';
fFlagged := False;
fDependencies := nil;
fDependenciesCount := 0;
fDependents := nil;
fDependentsCount := 0;
fIndirDependencies := nil;
fIndirDependenciesCount := 0;
fIndirDependents := nil;
fIndirDependentsCount := 0;
end;

//------------------------------------------------------------------------------

procedure TDTProject.Finalize;
begin
SetLength(fDependencies,0);
fDependenciesCount := 0;
SetLength(fDependents,0);
fDependentsCount := 0; 
SetLength(fIndirDependencies,0);
fIndirDependenciesCount := 0;
SetLength(fIndirDependents,0);
fIndirDependentsCount := 0;
end;

//------------------------------------------------------------------------------

procedure TDTProject.LoadFromStream(Stream: TStream);
begin
fName := Stream_GetString(Stream);
fProjectType := NumToProjectType(Stream_GetUInt8(Stream));
fRepositoryURL := Stream_GetString(Stream);
fProjectDir := Stream_GetString(Stream);
fNotes := Stream_GetString(Stream);
fFlagged := Stream_GetBoolean(Stream);
end;

{-------------------------------------------------------------------------------
    TDTProject - public methods
-------------------------------------------------------------------------------}

constructor TDTProject.Create(const Name: String);
begin
inherited Create(4);
Initialize(Name);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor TDTProject.Create(Stream: TStream);
begin
Create('');
LoadFromStream(Stream);
end;

//------------------------------------------------------------------------------

destructor TDTProject.Destroy;
begin
Finalize;
inherited;
end;

//------------------------------------------------------------------------------

procedure TDTProject.BeginInterlockedOperations;
begin
fInterlockedOpsFlags := fInterlockedOpsFlags + DT_INTERLOCKOPS_ALL;
end;

//------------------------------------------------------------------------------

procedure TDTProject.EndInterlockedOperations;
begin
fInterlockedOpsFlags := fInterlockedOpsFlags - DT_INTERLOCKOPS_ALL;
end;

//------------------------------------------------------------------------------

Function TDTProject.BeginInterlockedOperation(Operation: TDTInterlockedOperation): Boolean;
begin
Result := not(Operation in fInterlockedOpsFlags);
Include(fInterlockedOpsFlags,Operation);
end;

//------------------------------------------------------------------------------

procedure TDTProject.EndInterlockedOperation(Operation: TDTInterlockedOperation);
begin
Exclude(fInterlockedOpsFlags,Operation);
end;

//------------------------------------------------------------------------------

Function TDTProject.LowIndex(List: Integer): Integer;
begin
case List of
  DT_PROJLIST_DEPENDENCIES:       Result := Low(fDependencies);
  DT_PROJLIST_DEPENDENTS:         Result := Low(fDependents);
  DT_PROJLIST_INDIR_DEPENDENCIES: Result := Low(fIndirDependencies);
  DT_PROJLIST_INDIR_DEPENDENTS:   Result := Low(fIndirDependents);
else
  raise EDTInvalidValue.CreateFmt('TDTProject.LowIndex: Invalid list (%d).',[List]);
end;
end;

//------------------------------------------------------------------------------

Function TDTProject.HighIndex(List: Integer): Integer;
begin
case List of
  DT_PROJLIST_DEPENDENCIES:       Result := Pred(fDependenciesCount);
  DT_PROJLIST_DEPENDENTS:         Result := Pred(fDependentsCount);
  DT_PROJLIST_INDIR_DEPENDENCIES: Result := Pred(fIndirDependenciesCount);
  DT_PROJLIST_INDIR_DEPENDENTS:   Result := Pred(fIndirDependentsCount);
else
  raise EDTInvalidValue.CreateFmt('TDTProject.HighIndex: Invalid list (%d).',[List]);
end;
end;

//------------------------------------------------------------------------------

Function TDTProject.DependenciesLowIndex: Integer;
begin
Result := Low(fDependencies);
end;

//------------------------------------------------------------------------------

Function TDTProject.DependenciesHighIndex: Integer;
begin
Result := Pred(fDependenciesCount);
end;

//------------------------------------------------------------------------------

Function TDTProject.DependenciesCheckIndex(Index: Integer): Boolean;
begin
Result := (Index >= DependenciesLowIndex) and (Index <= DependenciesHighIndex);
end;

//------------------------------------------------------------------------------

Function TDTProject.DependentsLowIndex: Integer;
begin
Result := Low(fDependents);
end;

//------------------------------------------------------------------------------

Function TDTProject.DependentsHighIndex: Integer;
begin
Result := Pred(fDependentsCount);
end;

//------------------------------------------------------------------------------

Function TDTProject.DependentsCheckIndex(Index: Integer): Boolean;
begin
Result := (Index >= DependentsLowIndex) and (Index <= DependentsHighIndex);
end;

//------------------------------------------------------------------------------

Function TDTProject.IndirectDependenciesLowIndex: Integer;
begin
Result := Low(fIndirDependencies);
end;

//------------------------------------------------------------------------------

Function TDTProject.IndirectDependenciesHighIndex: Integer;
begin
Result := Pred(fIndirDependenciesCount);
end;

//------------------------------------------------------------------------------

Function TDTProject.IndirectDependenciesCheckIndex(Index: Integer): Boolean;
begin
Result := (Index >= IndirectDependenciesLowIndex) and (Index <= IndirectDependenciesHighIndex);
end;

//------------------------------------------------------------------------------

Function TDTProject.IndirectDependentsLowIndex: Integer;
begin
Result := Low(fIndirDependents);
end;

//------------------------------------------------------------------------------

Function TDTProject.IndirectDependentsHighIndex: Integer;
begin
Result := Pred(fIndirDependentsCount);
end;

//------------------------------------------------------------------------------

Function TDTProject.IndirectDependentsCheckIndex(Index: Integer): Boolean;
begin
Result := (Index >= IndirectDependentsLowIndex) and (Index <= IndirectDependentsHighIndex);
end;

//------------------------------------------------------------------------------

Function TDTProject.DependenciesIndexOf(Dependency: TDTProject): Integer;
var
  i:  Integer;
begin
Result := -1;
For i := DependenciesLowIndex to DependenciesHighIndex do
  If fDependencies[i].BoundObject = Dependency then
    begin
      Result := i;
      Break{For i};
    end;
end;

//------------------------------------------------------------------------------

Function TDTProject.DependenciesFind(Dependency: TDTProject; out Index: Integer): Boolean;
begin
Index := DependenciesIndexOf(Dependency);
Result := DependenciesCheckIndex(Index);
end;

//------------------------------------------------------------------------------

Function TDTProject.DependenciesAdd(Dependency: TDTProject): Integer;
var
  i:  Integer;
begin
If Dependency <> Self then
  begin
    If not DependenciesFind(Dependency,Result) then
      begin
        Grow(DT_PROJLIST_DEPENDENCIES);
        // sorted addition... get insertion index
        Result := DependenciesLowIndex;
        while Result <= DependenciesHighIndex do
          begin
            If StringCompare((fDependencies[Result].BoundObject as TDTProject).Name,Dependency.Name,False) > 0 then
              Break{For i};
            Inc(Result);
          end;
        For i := DependenciesHighIndex downto Result do
          fDependencies[i + 1] := fDependencies[i];
        fDependencies[Result].BoundObject := Dependency;
        fDependencies[Result].Conditional := False;
        fDependencies[Result].ConditionNotes := '';
        fDependencies[Result].IsAlsoIndirect := False;
        Inc(fDependenciesCount);
        // add self as dependent
        EnumerateIndirectDependencies;
        Dependency.DependentsAdd(Self);
        Dependency.EnumerateIndirectDependents;
      end;
  end
else Result := -1;
end;

//------------------------------------------------------------------------------

Function TDTProject.DependenciesRemove(Dependency: TDTProject): Integer;
begin
If DependenciesFind(Dependency,Result) then
  DependenciesDelete(Result);
end;

//------------------------------------------------------------------------------

procedure TDTProject.DependenciesDelete(Index: Integer);
var
  i:  Integer;
begin
If DependenciesCheckIndex(Index) then
  begin
    with fDependencies[Index].BoundObject as TDTProject do
      begin
        DependentsRemove(Self);
        EnumerateIndirectDependents;
      end;
    For i := Index to Pred(DependenciesHighIndex) do
      fDependencies[i] := fDependencies[i + 1];
    fDependencies[DependenciesHighIndex].BoundObject := nil;
    fDependencies[DependenciesHighIndex].Conditional := False;
    fDependencies[DependenciesHighIndex].ConditionNotes := '';
    fDependencies[DependenciesHighIndex].IsAlsoIndirect := False;
    Dec(fDependenciesCount);
    Shrink(DT_PROJLIST_DEPENDENCIES);
    EnumerateIndirectDependencies;
  end
else raise EDTIndexOutOfBounds.CreateFmt('TDTProject.DependenciesDelete: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

procedure TDTProject.DependenciesClear;
var
  i:  Integer;
begin
For i := DependenciesLowIndex to DependenciesHighIndex do
  (fDependencies[i].BoundObject as TDTProject).DependentsRemove(Self);
For i := DependenciesLowIndex to DependenciesHighIndex do
  (fDependencies[i].BoundObject as TDTProject).EnumerateIndirectDependents;
SetLength(fDependencies,0);
fDependenciesCount := 0;
SetLength(fIndirDependencies,0);
fIndirDependenciesCount := 0;
end;

//------------------------------------------------------------------------------

Function TDTProject.IndirectDependenciesFind(Dependency: TDTProject; out Index: Integer): Boolean;
var
  i:  Integer;
begin
Index := -1;
Result := False;
For i := IndirectDependenciesLowIndex to IndirectDependenciesHighIndex do
  If fIndirDependencies[i] = Dependency then
    begin
      Index := i;
      Result := True;
      Break{For i};
    end;
end;

//------------------------------------------------------------------------------

procedure TDTProject.EnumerateIndirectDependencies;
var
  Vector:   TDTAuxProjectVector;
  i,j,Idx:  Integer;
  Dummy:    Integer;
begin
If BeginInterlockedOperation(iopDepsEnum) then
try
  Vector := TDTAuxProjectVector.Create;
  try
    For i := DependenciesLowIndex to DependenciesHighIndex do
      (fDependencies[i].BoundObject as TDTProject).EnumerateDependencies(Vector);
    Vector.Remove(Self);
    // look for direct deps. in indirect (and remove them)
    For i := DependenciesLowIndex to DependenciesHighIndex do
      If Vector.Find(fDependencies[i].BoundObject as TDTProject,Idx) then
        begin
        {
          Look if the i-th dependency is also an indirect dependency, but not
          in its own (indirect) dependencies.
        }
          fDependencies[i].IsAlsoIndirect := False;
          For j := DependenciesLowIndex to DependenciesHighIndex do
            If i <> j then
              If Dependencies[j].DependenciesFind(Dependencies[i],Dummy) or
                 Dependencies[j].IndirectDependenciesFind(Dependencies[i],Dummy) then
                begin
                  fDependencies[i].IsAlsoIndirect := True;
                  Break{For j};
                end;
          Vector.Delete(Idx);
        end
      else fDependencies[i].IsAlsoIndirect := False;
    // copy the list
    fIndirDependenciesCount := Vector.Count;
    SetLength(fIndirDependencies,fIndirDependenciesCount);
    For i := Vector.LowIndex to Vector.HighIndex do
      fIndirDependencies[i] := Vector[i];
  finally
    Vector.Free;
  end;
finally
  EndInterlockedOperation(iopDepsEnum);
end;
end;

//------------------------------------------------------------------------------

procedure TDTProject.EnumerateIndirectDependents;
var
  Vector: TDTAuxProjectVector;
  i:      Integer;
begin
If BeginInterlockedOperation(iopDpdsEnum) then
try
  Vector := TDTAuxProjectVector.Create;
  try
    For i := DependentsLowIndex to DependentsHighIndex do
      fDependents[i].EnumerateDependents(Vector);
    Vector.Remove(Self);
    For i := DependentsLowIndex to DependentsHighIndex do
      Vector.Remove(fDependents[i]);
    fIndirDependentsCount := Vector.Count;
    SetLength(fIndirDependents,fIndirDependentsCount);
    For i := Vector.LowIndex to Vector.HighIndex do
      fIndirDependents[i] := Vector[i];
  finally
    Vector.Free;
  end;
finally
  EndInterlockedOperation(iopDpdsEnum);
end;
end;

//------------------------------------------------------------------------------

Function TDTProject.FullName: String;
begin
If fProjectType <> ptOthers then
  begin
    If fFlagged then
      Result := Format('(%s)*%s',[DT_PROJTYPE_TAGS[fProjectType],fName])
    else
      Result := Format('(%s) %s',[DT_PROJTYPE_TAGS[fProjectType],fName]);
  end
else Result := Format('      %s',[fName]);
end;

//------------------------------------------------------------------------------

procedure TDTProject.SaveToStream(Stream: TStream);
begin
Stream_WriteString(Stream,fName);
Stream_WriteUInt8(Stream,ProjectTypeToNum(fProjectType));
Stream_WriteString(Stream,fRepositoryURL);
Stream_WriteString(Stream,fProjectDir);
Stream_WriteString(Stream,fNotes);
Stream_WriteBoolean(Stream,fFlagged);
end;

//------------------------------------------------------------------------------

Function TDTProject.CreateDependencyReport: TStrings;

  Function CondPrefix(Conditional: Boolean): String;
  begin
    If Conditional then
      Result := '  * '
    else
      Result := '    ';
  end;

  procedure WordWrapAdd(Strs: TStrings; const Text: String);
  var
    i,SpcPos: Integer;
  begin
    If Length(Text) > 78 then
      begin
        SpcPos := 0;
        For i := 78 downto 1 do
          If Text[i] = ' ' then
            begin
              SpcPos := i;
              Break{For i};
            end;
        If SpcPos <= 0 then
          For i := 79 to Length(Text) do
            If Text[i] = ' ' then
              begin
                SpcPos := i;
                Break{For i};
              end;
        If SpcPos > 0 then
          begin
            Strs.Add('  ' + Copy(Text,1,SpcPos - 1));
            WordWrapAdd(Strs,Copy(Text,SpcPos + 1,Length(Text)));
          end
        else Strs.Add('  ' + Text);
      end
    else Strs.Add('  ' + Text);
  end;

var
  i:        Integer;
  MaxW:     Integer;
  TempList: TStringList;
  TempText: String;
begin
{
  NOTE - this has wery specific formatting and as such probably will not be of
         any use for users other than the author.
}
Result := TStringList.Create;
// direct dependecies...
Result.Add('  Dependencies:');
If DependenciesCount > 0 then
  begin
    // list direct dependecies
    MaxW := 0;
    For i := DependenciesLowIndex to DependenciesHighIndex do
      If Length(Dependencies[i].Name) > MaxW then
        MaxW := Length(Dependencies[i].Name);
    For i := DependenciesLowIndex to DependenciesHighIndex do
      begin
        If Length(Dependencies[i].RepositoryURL) > 0 then
          Result.Add(CondPrefix(fDependencies[i].Conditional) + Dependencies[i].Name +
                     StringOfChar(' ',MaxW - Length(Dependencies[i].Name)) +
                     ' - ' + Dependencies[i].RepositoryURL)
        else
          Result.Add(CondPrefix(fDependencies[i].Conditional) + Dependencies[i].Name);
      end;
    // direct dependencies contition notes
    For i := DependenciesLowIndex to DependenciesHighIndex do
      If fDependencies[i].Conditional and (Length(fDependencies[i].ConditionNotes) > 0) then
        begin
          Result.Add(''); // an empty line
          WordWrapAdd(Result,fDependencies[i].ConditionNotes);
        end;
    // notes on conditional deps. that are also in indirect deps.
    TempList := TStringList.Create;
    try
      For i := DependenciesLowIndex to DependenciesHighIndex do
        If fDependencies[i].Conditional and fDependencies[i].IsAlsoIndirect then
          TempList.Add(Dependencies[i].Name);
      If TempList.Count > 0 then
        begin
          Result.Add('');
          If TempList.Count > 2 then
            begin
              TempText := '';
              For i := 0 to Pred(TempList.Count) do
                If Length(TempText) > 0 then
                  begin
                    If i < Pred(TempList.Count) then
                      TempText := TempText + ', '
                    else
                      TempText := TempText + ' and ';
                    TempText := TempText + TempList[i];
                  end
                else TempText := TempList[i];
              WordWrapAdd(Result,Format('Libraries %s might also be required as an indirect dependencies.',[TempText]));
            end
          else If TempList.Count > 1 then
            WordWrapAdd(Result,Format('Libraries %s and %s might also be required as an indirect dependencies.',[TempList[0],TempList[1]]))
          else
            WordWrapAdd(Result,Format('Library %s might also be required as an indirect dependency.',[TempList[0]]));
        end;
    finally
      TempList.Free;
    end;
    // indirect dependecies...
    If IndirectDependenciesCount > 0 then
      begin
        Result.Add('');
        Result.Add('  Indirect dependencies:');
        // list indirect dependecies
        MaxW := 0;
        For i := IndirectDependenciesLowIndex to IndirectDependenciesHighIndex do
          If Length(fIndirDependencies[i].Name) > MaxW then
            MaxW := Length(fIndirDependencies[i].Name);
        For i := IndirectDependenciesLowIndex to IndirectDependenciesHighIndex do
          begin
            If Length(fIndirDependencies[i].RepositoryURL) > 0 then
              Result.Add('    ' + fIndirDependencies[i].Name +
                         StringOfChar(' ',MaxW - Length(fIndirDependencies[i].Name)) +
                         ' - ' + fIndirDependencies[i].RepositoryURL)
            else
              Result.Add('    ' + fIndirDependencies[i].Name);
          end;
      end;
  end
else Result.Add('    none')
end;

//------------------------------------------------------------------------------

Function TDTProject.CreateDependencyTree: TStrings;

  procedure CheckCompact(Node: PDTTreeNode);
  var
    i:    Integer;
    Temp: Boolean;
  begin
    If Length(Node^.SubNodes) > 0 then
      begin
        Temp := True;
        For i := Low(Node^.SubNodes) to High(Node^.SubNodes) do
          begin
            CheckCompact(Node^.SubNodes[i]);
            If not Node^.SubNodes[i]^.CompactSubTree then
              Temp := False;
          end;
        If not Temp then
          For i := Low(Node^.SubNodes) to High(Node^.SubNodes) do
            Node^.SubNodes[i]^.CompactSubTree := False;
        If Length(Node^.SubNodes) = 1 then
          Node^.CompactSubTree := Node^.SubNodes[0]^.CompactSubTree
        else
          Node^.CompactSubTree := False;
      end
    else Node^.CompactSubTree := True;
  end;

//--  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --    

  procedure ProcessNode(Node: PDTTreeNode);
  var
    i:        Integer;
    NodeStr:  String;
  begin
    For i := Low(Node^.SubNodes) to High(Node^.SubNodes) do
      begin
        If not Node^.UnconditionalOnly then
          begin
            If Node^.SubNodes[i]^.Conditional then
              NodeStr := '* ' + Node^.SubNodes[i]^.Project.Name
            else
              NodeStr := '  ' + Node^.SubNodes[i]^.Project.Name;
          end
        else NodeStr := Node^.SubNodes[i]^.Project.Name;
        If Node^.SubNodes[i]^.Repeating then
          NodeStr := NodeStr + ' (...)';
        If i <= Low(Node^.SubNodes) then
          Node^.SubNodes[i]^.StringBuilding.NodePath := Node^.StringBuilding.NodePath + ' --- ' + NodeStr
        else
          Node^.SubNodes[i]^.StringBuilding.NodePath := Node^.StringBuilding.NextPath + '  |- ' + NodeStr;
        Node^.SubNodes[i]^.StringBuilding.NextPath := Node^.StringBuilding.NextPath +
          IfThen(i < High(Node^.SubNodes),'  |  ','     ') + StringOfchar(' ',Length(NodeStr));
        If Length(Node^.SubNodes[i]^.SubNodes) <= 0 then
          Result.Add(Node^.SubNodes[i]^.StringBuilding.NodePath);
        ProcessNode(Node^.SubNodes[i]);         
        If not Node^.SubNodes[i]^.CompactSubTree and (i < High(Node^.SubNodes)) then
          Result.Add(TrimRight(Node^.SubNodes[i]^.StringBuilding.NextPath));
      end;
  end;

//--  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --

  procedure FreeNode(var Node: PDTTreeNode);
  var
    i:  Integer;
  begin
    For i := Low(Node^.SubNodes) to High(Node^.SubNodes) do
      FreeNode(Node^.SubNodes[i]);
    Node^.SubNodes := nil;
    Dispose(Node);
    Node := nil;
  end;

var
  BaseNode: PDTTreeNode;
begin
{
  Creates tree in the form:

    Item_A --- Item_1 --- Item_I
            |          |- Item_II
            |          |- Item_III
            |
            |- Item_2 --- Item_IV
            |
            |- Item_3 --- Item_V --- Item_a
                       |
                       |- Item_VI --- Item_b
                                   |- Item_c
}
Result := TStringList.Create;
New(BaseNode);
try
  EnumerateTree(BaseNode);
  CheckCompact(BaseNode);
  BaseNode^.StringBuilding.NodePath := Name;
  BaseNode^.StringBuilding.NextPath := StringOfChar(' ',Length(Name));
  ProcessNode(BaseNode);
finally
  FreeNode(BaseNode);
end;
end;

end.

