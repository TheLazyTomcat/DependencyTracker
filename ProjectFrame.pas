{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ProjectFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Menus,
  DepsTracker_Common, DepsTracker_Project, DepsTracker_Manager;

type
  TfrmProjectFrame = class(TFrame)
    pnlBackgroundPanel: TPanel;
    shpNameBackground: TShape;
    shpFlagged: TShape;    
    lblName: TLabel;
    lblType: TLabel;
    cbType: TComboBox;
    leRepositoryURL: TLabeledEdit;
    btnOpenRepURL: TButton;
    leProjectDir: TLabeledEdit;
    btnBrowseProjectDir: TButton;
    btnOpenProjectDir: TButton;
    lblNotes: TLabel;
    meNotes: TMemo;
    lblEditNotes: TLabel;
    pmListing: TPopupMenu;
    pmiListing: TMenuItem;
    pmiListing_Comma: TMenuItem;
    pmiListing_Line: TMenuItem;
    lblDependencies: TLabel;
    lbDependencies: TListBox;
    btnManageDeps: TButton;
    btnDepReport: TButton;
    btnDepTree: TButton;    
    cbConditionDep: TCheckBox;
    meConditionNotes: TMemo;
    lblEditCondNotes: TLabel;
    bvlSplitter: TBevel;
    lblIndirectDeps: TLabel;
    lbIndirectDeps: TListBox;
    lblDependents: TLabel;
    lbDependents: TListBox;
    procedure lblNameDblClick(Sender: TObject);
    procedure cbTypeChange(Sender: TObject);
    procedure btnOpenRepURLClick(Sender: TObject);
    procedure btnBrowseProjectDirClick(Sender: TObject);
    procedure btnOpenProjectDirClick(Sender: TObject);
    procedure lblEditNotesMouseEnter(Sender: TObject);
    procedure lblEditNotesMouseLeave(Sender: TObject);
    procedure lblEditNotesClick(Sender: TObject);
    procedure meNotesKeyPress(Sender: TObject; var Key: Char);
    procedure pmiListing_CommonClick(Sender: TObject);
    procedure lbDependenciesClick(Sender: TObject);
    procedure lbDependenciesDblClick(Sender: TObject);    
    procedure btnManageDepsClick(Sender: TObject);
    procedure btnDepReportClick(Sender: TObject);
    procedure btnDepTreeClick(Sender: TObject);
    procedure cbConditionDepClick(Sender: TObject);
    procedure lblEditCondNotesMouseEnter(Sender: TObject);
    procedure lblEditCondNotesMouseLeave(Sender: TObject);
    procedure lblEditCondNotesClick(Sender: TObject);
    procedure meConditionNotesKeyPress(Sender: TObject; var Key: Char);
    procedure lbIndirectDepsDblClick(Sender: TObject);
    procedure lbDependentsDblClick(Sender: TObject);
  private
    { Private declarations }
  protected
    fProject:       TDTProject;
    fLoadingFrame:  Boolean;
    fSelDependency: TDTProject;
    fSelDepIndex:   Integer;
    procedure LoadDependenciesList;
    procedure LoadIndirectDependenciesList;
    procedure LoadDependentsList;
    procedure LoadLists;
    procedure SetDependency(Project: TDTProject);
    procedure LoadDependency;
    procedure SaveDependency;
  public
    OnListChange: TDTProjectEvent;
    OnListSelect: TDTProjectEvent;
    procedure Initialize;
    procedure LoadFrame;
    procedure SaveFrame;
    procedure UpdateLists;
    procedure UpdateFlagged;
    procedure SetItem(Project: TDTProject);
  end;

implementation

uses
  ShellAPI, StrUtils, {$WARN UNIT_PLATFORM OFF}FileCtrl,{$WARN UNIT_PLATFORM ON} 
  StrRect,
  ProjectNameForm, TextEditForm, ProjectsSelectForm;

{$R *.dfm}

procedure TfrmProjectFrame.LoadDependenciesList;
var
  i:  Integer;
begin
while lbDependencies.Count < fProject.DependenciesCount do
  lbDependencies.Items.Add('');
while lbDependencies.Count > fProject.DependenciesCount do
  lbDependencies.Items.Delete(Pred(lbDependencies.Count));
For i := fProject.DependenciesLowIndex to fProject.DependenciesHighIndex do
  If fProject.DependenciesInfo[i].Conditional then
    begin
      If fProject.DependenciesInfo[i].IsAlsoIndirect then
        lbDependencies.Items[i] := '! ' + fProject.Dependencies[i].Name
      else
        lbDependencies.Items[i] := '* ' + fProject.Dependencies[i].Name;
    end
  else lbDependencies.Items[i] := '  ' + fProject.Dependencies[i].Name;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.LoadIndirectDependenciesList;
var
  i:  Integer;
begin
while lbIndirectDeps.Count < fProject.IndirectDependenciesCount do
  lbIndirectDeps.Items.Add('');
while lbIndirectDeps.Count > fProject.IndirectDependenciesCount do
  lbIndirectDeps.Items.Delete(Pred(lbIndirectDeps.Count));
For i := fProject.IndirectDependenciesLowIndex to fProject.IndirectDependenciesHighIndex do
  lbIndirectDeps.Items[i] := fProject.IndirectDependencies[i].Name;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.LoadDependentsList;
var
  i:          Integer;
  IndirDpds:  Boolean;
begin
// load both direct and indirect dependents
while lbDependents.Count < (fProject.DependentsCount + fProject.IndirectDependentsCount) do
  lbDependents.Items.Add('');
while lbDependents.Count > (fProject.DependentsCount + fProject.IndirectDependentsCount) do
  lbDependents.Items.Delete(Pred(lbDependents.Count));
IndirDpds := fProject.IndirectDependentsCount > 0;
// direct dependents...
For i := fProject.DependentsLowIndex to fProject.DependentsHighIndex do
  If IndirDpds then
    lbDependents.Items[i] := Format(' %s',[fProject.Dependents[i].Name])
  else
    lbDependents.Items[i] := fProject.Dependents[i].Name;
// indirect dependents...
For i := fProject.IndirectDependentsLowIndex to fProject.IndirectDependentsHighIndex do
  lbDependents.Items[fProject.DependentsCount + i] := Format('(%s)',[fProject.IndirectDependents[i].Name])
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.LoadLists;
begin
LoadDependenciesList;
LoadIndirectDependenciesList;
LoadDependentsList;
If lbDependencies.Count > 0 then
  lbDependencies.ItemIndex := 0
else
  lbDependencies.ItemIndex := -1;
lbDependencies.OnClick(Self);
If lbIndirectDeps.Count > 0 then
  lbIndirectDeps.ItemIndex := 0
else
  lbIndirectDeps.ItemIndex := -1;
If lbDependents.Count > 0 then
  lbDependents.ItemIndex := 0
else
  lbDependents.ItemIndex := -1;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.SetDependency(Project: TDTProject);
var
  Index:  Integer;
begin
SaveDependency;
If Assigned(Project) and fProject.DependenciesFind(Project,Index) then
  begin
    fSelDependency := Project;
    fSelDepIndex := Index;
  end
else
  begin
    fSelDependency := nil;
    fSelDepIndex := -1;
  end;
cbConditionDep.Enabled := Assigned(fSelDependency);
lblEditCondNotes.Enabled := cbConditionDep.Enabled;
meConditionNotes.Enabled := cbConditionDep.Enabled;
LoadDependency;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.LoadDependency;
begin
If Assigned(fSelDependency) then
  begin
    cbConditionDep.Checked := fProject.DependenciesInfo[fSelDepIndex].Conditional;
    meConditionNotes.Text := fProject.DependenciesInfo[fSelDepIndex].ConditionNotes;
  end
else
  begin
    cbConditionDep.Checked := False;
    meConditionNotes.Text := '';
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.SaveDependency;
begin
If Assigned(fSelDependency) then
  fProject.DependenciesInfoPtr[fSelDepIndex]^.ConditionNotes := meConditionNotes.Text;
end;

//==============================================================================

procedure TfrmProjectFrame.Initialize;
var
  i:  TDTProjectType;
begin
For i := Low(DT_PROJTYPE_STRS) to High(DT_PROJTYPE_STRS) do
  cbType.Items.Add(DT_PROJTYPE_STRS[i]);
cbType.ItemIndex := 0;
fProject := nil;
fLoadingFrame := False;
fSelDependency := nil;
fSelDepIndex := -1;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.LoadFrame;
begin
If Assigned(fProject) then
  begin
    fLoadingFrame := True;
    try
      UpdateFlagged;
      lblName.Caption := fProject.Name;
      cbType.ItemIndex := Ord(fProject.ProjectType);
      leRepositoryURL.Text := fProject.RepositoryURL;
      leProjectDir.Text := fProject.ProjectDirector;
      meNotes.Text := fProject.Notes;
      LoadLists;
    finally
      fLoadingFrame := False;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.SaveFrame;
begin
If Assigned(fProject) then
  begin
    fProject.RepositoryURL := leRepositoryURL.Text;
    fProject.Notes := meNotes.Text;
    fProject.ProjectDirector := leProjectDir.Text;
    SaveDependency;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.UpdateLists;
var
  IndirDepsIdx: Integer;
  IndirDpdsIdx: Integer;
  Index:        Integer;
begin
If Assigned(fProject) then
  begin
    IndirDepsIdx := lbIndirectDeps.ItemIndex;
    IndirDpdsIdx := lbDependents.ItemIndex;
    LoadDependenciesList;
    LoadIndirectDependenciesList;
    LoadDependentsList;
    If fProject.DependenciesFind(fSelDependency,Index) then
      begin
        lbDependencies.ItemIndex := Index;
        fSelDepIndex := Index;
      end
    else
      begin
        fSelDependency := nil;
        fSelDepIndex := -1;
        If lbDependencies.Count > 0 then
          lbDependencies.ItemIndex := 0
        else
          lbDependencies.ItemIndex := -1;
        lbDependencies.OnClick(Self);
      end;
    If lbIndirectDeps.Count <= 0 then
      lbIndirectDeps.ItemIndex := -1
    else If IndirDepsIdx >= lbIndirectDeps.Count then
      lbIndirectDeps.ItemIndex := Pred(lbIndirectDeps.Count);
    If lbDependents.Count <= 0 then
      lbDependents.ItemIndex := -1
    else If IndirDpdsIdx >= lbDependents.Count then
      lbDependents.ItemIndex := Pred(lbDependents.Count);
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.UpdateFlagged;
begin
If Assigned(fProject) then
  shpFlagged.Visible := fProject.Flagged;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.SetItem(Project: TDTProject);
begin
If fProject <> Project then
  begin
    SaveFrame;
    fProject := Project;
    fSelDependency := nil;
    fSelDepIndex := -1;
    LoadFrame;
  end;
Visible := Assigned(fProject);
end;

//==============================================================================

procedure TfrmProjectFrame.lblNameDblClick(Sender: TObject);
var
  Name: String;
begin
Name := fProject.Name;
If fProjectNameForm.Prompt('Rename project',Name) then
  begin
    fProject.Name := Name;
    If Assigned(OnListChange) then
      OnListChange(Self,fProject);
    lblName.Caption := fProject.Name; 
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.cbTypeChange(Sender: TObject);
begin
If not fLoadingFrame then
  begin
    fProject.ProjectType := TDTProjectType(cbType.ItemIndex);
    If Assigned(OnListChange) then
      OnListChange(Self,fProject);
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.btnOpenRepURLClick(Sender: TObject);
var
  FullURL:  String;
begin
If Length(leRepositoryURL.Text) > 0 then
  begin
    FullURL := leRepositoryURL.Text;
    If not AnsiStartsText('https://',FullURL) then
      FullURL := 'https://' + FullURL;
    ShellExecute(Self.Handle,'open',PChar(StrToWin(FullURL)),nil,nil,SW_SHOWNORMAL)
  end
else MessageDlg('Cannot open an empty URL.',mtInformation,[mbOk],0);
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.btnBrowseProjectDirClick(Sender: TObject);
var
  DirPath:  String;
begin
If Length(leProjectDir.Text) > 0 then
  DirPath := leProjectDir.Text
else
  DirPath := ExtractFileDir(ParamStr(0));
If SelectDirectory(StrToWide('Select project directory'),StrToWide(''),DirPath) then
  leProjectDir.Text := DirPath;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.btnOpenProjectDirClick(Sender: TObject);
begin
If Length(leProjectDir.Text) > 0 then
  ShellExecute(Self.Handle,'open',PChar(StrToWin(leProjectDir.Text)),nil,nil,SW_SHOWNORMAL)
else
  MessageDlg('Cannot open an empty directory path.',mtInformation,[mbOk],0);
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.lblEditNotesMouseEnter(Sender: TObject);
begin
lblEditNotes.Font.Style := [fsBold];
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.lblEditNotesMouseLeave(Sender: TObject);
begin
lblEditNotes.Font.Style := [];
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.lblEditNotesClick(Sender: TObject);
var
  Text: String;
begin
Text := meNotes.Text;
fTextEditForm.ShowTextEditor(Format('%s - project notes',[fProject.Name]),Text,False);
meNotes.Text := Text;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.meNotesKeyPress(Sender: TObject; var Key: Char);
begin
If Key = ^A then
  begin
    meNotes.SelectAll;
    Key := #0;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.pmiListing_CommonClick(Sender: TObject);
var
  Delim,Text,Cap: String;
  i:              Integer;
  NoDelim:        Boolean;

  procedure AppendToText(const Str: String);
  begin
    If NoDelim then
      Text := Text + Str
    else
      Text := Text + Delim + Str;
    NoDelim := False;
  end;

begin
If Sender = pmiListing_Comma then
  Delim := ', '
else
  Delim := sLineBreak;
Text := '';
Cap := '';
NoDelim := True;
If Assigned(fProject) then
  case pmListing.PopupComponent.Tag of
    1:  begin
          For i := fProject.DependenciesLowIndex to fProject.DependenciesHighIndex do
            AppendToText(fProject.Dependencies[i].Name);
          Cap := 'direct dependencies';
        end;
    2:  begin
          For i := fProject.IndirectDependenciesLowIndex to fProject.IndirectDependenciesHighIndex do
            AppendToText(fProject.IndirectDependencies[i].Name);
          Cap := 'indirect dependencies';
        end;
    3:  begin
          For i := fProject.DependentsLowIndex to fProject.DependentsHighIndex do
            AppendToText(fProject.Dependents[i].Name);
          If fProject.IndirectDependentsCount > 0 then
            begin
              If Sender = pmiListing_Comma then
                begin
                  AppendToText('(');
                  NoDelim := True;
                  For i := fProject.IndirectDependentsLowIndex to fProject.IndirectDependentsHighIndex do
                    AppendToText(fProject.IndirectDependents[i].Name);
                  Text := Text + ')';
                end
              else
                For i := fProject.IndirectDependentsLowIndex to fProject.IndirectDependentsHighIndex do
                  AppendToText(Format('(%s)',[fProject.IndirectDependents[i].Name]));
              Cap := '(indirect) dependents';
            end
          else Cap := 'dependents';
        end;
  else
    MessageDlg('Unknown list.',mtError,[mbOK],0);
  end;
fTextEditForm.ShowTextEditor(Format('%s - %s',[fProject.Name,Cap]),Text,False);
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.lbDependenciesClick(Sender: TObject);
begin
If lbDependencies.ItemIndex >= 0 then
  SetDependency(fProject.Dependencies[lbDependencies.ItemIndex])
else
  SetDependency(nil);
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.lbDependenciesDblClick(Sender: TObject);
begin
If (lbDependencies.ItemIndex >= 0) and Assigned(fSelDependency) and Assigned(OnListSelect) then
  If lbDependencies.ItemAtPos(lbDependencies.ScreenToClient(Mouse.CursorPos),True) >= 0 then
    OnListSelect(Self,fSelDependency);
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.btnManageDepsClick(Sender: TObject);
var
  Projects: TDTProjectArray;
  i:        Integer;

  Function ProjectListed(Project: TDTProject): Boolean;
  var
    ii: Integer;
  begin
    Result := False;
    For ii := Low(Projects) to High(Projects) do
      If Projects[ii] = Project then
        begin
          Result := True;
          Break{For ii};
        end;
  end;

begin
SetLength(Projects,fProject.DependenciesCount);
For i := fProject.DependenciesLowIndex to fProject.DependenciesHighIndex do
  Projects[i] := fProject.Dependencies[i];
If fProjectsSelectForm.SelectDependencies(fProject,Projects) then
  begin
    SaveDependency;
    For i := Low(Projects) to High(Projects) do
      fProject.DependenciesAdd(Projects[i]);
    For i := fProject.DependenciesHighIndex downto fProject.DependenciesLowIndex do
      If not ProjectListed(fProject.Dependencies[i]) then
        fProject.DependenciesDelete(i);
    If not fProject.DependenciesFind(fSelDependency,i) then
      begin
        fSelDependency := nil;
        fSelDepIndex := -1;
      end;
    UpdateLists;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.btnDepReportClick(Sender: TObject);
var
  Report: String;
begin
with fProject.CreateDependencyReport do
try
  Report := Text;
  If AnsiEndsText(sLineBreak,Report) then
    Report := Copy(Report,1,Length(Report) - Length(sLineBreak));
  fTextEditForm.ShowTextEditor(Format('%s - dependency report',[fProject.Name]),Report,False);
finally
  Free;
end;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.btnDepTreeClick(Sender: TObject);
var
  Tree: String;
begin
with fProject.CreateDependencyTree do
try
  Tree := Text;
  If AnsiEndsText(sLineBreak,Tree) then
    Tree := Copy(Tree,1,Length(Tree) - Length(sLineBreak));
  fTextEditForm.ShowTextEditor(Format('%s - dependency tree',[fProject.Name]),Tree,False);
finally
  Free;
end;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.cbConditionDepClick(Sender: TObject);
begin
If Assigned(fSelDependency) then
  begin
    fProject.DependenciesInfoPtr[fSelDepIndex]^.Conditional := cbConditionDep.Checked;
    LoadDependenciesList;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.lblEditCondNotesMouseEnter(Sender: TObject);
begin
lblEditCondNotes.Font.Style := [fsBold];
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.lblEditCondNotesMouseLeave(Sender: TObject);
begin
lblEditCondNotes.Font.Style := [];
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.lblEditCondNotesClick(Sender: TObject);
var
  Text: String;
begin
If Assigned(fSelDependency) then
  begin
    Text := meConditionNotes.Text;
    fTextEditForm.ShowTextEditor(Format('%s - %s dependency condition notes',
      [fProject.Name,fSelDependency.Name]),Text,False);
    meConditionNotes.Text := Text;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.meConditionNotesKeyPress(Sender: TObject;
  var Key: Char);
begin
If Key = ^A then
  begin
    meConditionNotes.SelectAll;
    Key := #0;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.lbIndirectDepsDblClick(Sender: TObject);
begin
If Assigned(fProject) and Assigned(OnListSelect) then
  If fProject.IndirectDependenciesCheckIndex(lbIndirectDeps.ItemIndex) then
    If lbIndirectDeps.ItemAtPos(lbIndirectDeps.ScreenToClient(Mouse.CursorPos),True) >= 0 then
      OnListSelect(Self,fProject.IndirectDependencies[lbIndirectDeps.ItemIndex]);
end;

//------------------------------------------------------------------------------

procedure TfrmProjectFrame.lbDependentsDblClick(Sender: TObject);
begin
If Assigned(fProject) and Assigned(OnListSelect) then
  If lbDependents.ItemAtPos(lbDependents.ScreenToClient(Mouse.CursorPos),True) >= 0 then
    If (lbDependents.ItemIndex >= 0) and
       (lbDependents.ItemIndex < (fProject.DependentsCount + fProject.IndirectDependentsCount)) then
      begin
        If lbDependents.ItemIndex > fProject.DependentsHighIndex then
          OnListSelect(Self,fProject.IndirectDependents[lbDependents.ItemIndex - fProject.DependentsCount])
        else
          OnListSelect(Self,fProject.Dependents[lbDependents.ItemIndex]);
      end;
end;   

end.
