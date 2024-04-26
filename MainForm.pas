{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, XPMan, Menus, ProjectFrame, ComCtrls, ActnList,
  DepsTracker_Project, DepsTracker_Manager;

type
  TfMainForm = class(TForm)
    lblProjects: TLabel;
    lbProjects: TListBox;
    pmProjects: TPopupMenu;
    pmiProjects_Add: TMenuItem;
    pmiProjects_Remove: TMenuItem;
    pmiProjects_RemoveAll: TMenuItem;
    N1: TMenuItem;
    pmiProjects_AddTemplate: TMenuItem;
    pmiProjects_TemplateSettings: TMenuItem;
    N2: TMenuItem;
    pmiProjects_List: TMenuItem;
    pmiProjects_FullNames: TMenuItem;
    pmiProjects_List_Comma: TMenuItem;
    pmiProjects_List_Line: TMenuItem;
    N3: TMenuItem;
    pmiProjects_FlagAll: TMenuItem;
    pmiProjects_UnflagAll: TMenuItem;
    pmiProjects_FlagToggle: TMenuItem;    
    N4: TMenuItem;
    pmiProjects_Save: TMenuItem;
    N5: TMenuItem;
    pmiProjects_ExitNS: TMenuItem;
    pmiProjects_Exit: TMenuItem;
    eSearchFor: TEdit;
    btnFindPrev: TButton;
    btnFindNext: TButton;
    grbProjectDetails: TGroupBox;
    frmProjectFrame: TfrmProjectFrame;
    oXPManifest: TXPManifest;
    sbStatusBar: TStatusBar;
    oActionList: TActionList;
    actPrevItem: TAction;
    actNextItem: TAction;
    actFind: TAction;
    actFindNext: TAction;
    actFindPrev: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbProjectsClick(Sender: TObject);
    procedure lbProjectsDblClick(Sender: TObject);
    procedure lbProjectsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pmProjectsPopup(Sender: TObject);
    procedure pmiProjects_AddClick(Sender: TObject);
    procedure pmiProjects_RemoveClick(Sender: TObject);
    procedure pmiProjects_RemoveAllClick(Sender: TObject);
    procedure pmiProjects_AddTemplateClick(Sender: TObject);
    procedure pmiProjects_TemplateSettingsClick(Sender: TObject);
    procedure pmiProjects_List_CommaClick(Sender: TObject);
    procedure pmiProjects_List_LineClick(Sender: TObject);
    procedure pmiProjects_FlagAllClick(Sender: TObject);
    procedure pmiProjects_UnflagAllClick(Sender: TObject);
    procedure pmiProjects_FlagToggleClick(Sender: TObject);
    procedure pmiProjects_SaveClick(Sender: TObject);
    procedure pmiProjects_ExitNSClick(Sender: TObject);
    procedure pmiProjects_ExitClick(Sender: TObject);
    procedure pmiProjects_FullNamesClick(Sender: TObject);
    procedure eSearchForEnter(Sender: TObject);
    procedure eSearchForExit(Sender: TObject);
    procedure eSearchForKeyPress(Sender: TObject; var Key: Char);
    procedure btnFindPrevClick(Sender: TObject);
    procedure btnFindNextClick(Sender: TObject);
    procedure actPrevItemExecute(Sender: TObject);
    procedure actNextItemExecute(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actFindPrevExecute(Sender: TObject);
    procedure actFindNextExecute(Sender: TObject);
  private
    { Private declarations }
  protected
    fSaveOnClose: Boolean;
    fMainFile:    String;
    procedure UpdateProjects;
    procedure UpdateStatus;
    procedure ListChangeHandler(Sender: TObject; Project: TDTProject);
    procedure ListSelectHandler(Sender: TObject; Project: TDTProject);
  public
    Manager:  TDTManager;  
    { Public declarations }
  end;

var
  fMainForm: TfMainForm;

implementation

uses
  WinFileInfo,
  ProjectNameForm, TextEditForm, TemplateSettingsForm;

{$R *.dfm}

procedure TfMainForm.UpdateProjects;
var
  i:  Integer;
begin
while lbProjects.Count > Manager.Count do
  lbProjects.Items.Delete(Pred(lbProjects.Count));
For i := 0 to Pred(lbProjects.Count) do
  lbProjects.Items[i] := Manager[i].FullName;
while lbProjects.Count < Manager.Count do
  lbProjects.Items.Add(Manager[lbProjects.Count].FullName);
end;

//------------------------------------------------------------------------------

procedure TfMainForm.UpdateStatus;
begin
If Manager.Count > 0 then
  sbStatusBar.Panels[0].Text := Format('%d / %d',[lbProjects.ItemIndex + 1,Manager.Count])
else
  sbStatusBar.Panels[0].Text := '- / -';
end;

//------------------------------------------------------------------------------

procedure TfMainForm.ListChangeHandler(Sender: TObject; Project: TDTProject);
begin
Manager.Sort;
lbProjects.ItemIndex := Manager.IndexOf(Project);
UpdateProjects;
UpdateStatus;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.ListSelectHandler(Sender: TObject; Project: TDTProject);
begin
lbProjects.ItemIndex := Manager.IndexOf(Project);
lbProjects.OnClick(Self);
end;

//==============================================================================

procedure TfMainForm.FormCreate(Sender: TObject);
begin
with TWinFileInfo.Create([lsaLoadVersionInfo,lsaLoadFixedFileInfo,lsaDecodeFixedFileInfo]) do
try
  sbStatusBar.Panels[2].Text := Format('%s, version %d.%d.%d %s%s #%d %s',[
    VersionInfoValues[VersionInfoTranslations[0].LanguageStr,'LegalCopyright'],
    VersionInfoFixedFileInfoDecoded.FileVersionMembers.Major,
    VersionInfoFixedFileInfoDecoded.FileVersionMembers.Minor,
    VersionInfoFixedFileInfoDecoded.FileVersionMembers.Release,
    {$IFDEF FPC}'L'{$ELSE}'D'{$ENDIF},{$IFDEF x64}'64'{$ELSE}'32'{$ENDIF},
    VersionInfoFixedFileInfoDecoded.FileVersionMembers.Build,
    {$IFDEF Debug}'debug'{$ELSE}'release'{$ENDIF}]);
finally
  Free;
end;
frmProjectFrame.Initialize;
frmProjectFrame.OnListChange := ListChangeHandler;
frmProjectFrame.OnListSelect := ListSelectHandler;
fSaveOnClose := True;
fMainFile := ExtractFilePath(ParamStr(0)) + TDTManager.DefaultFileName;
sbStatusBar.Panels[1].Text := fMainFile;
Manager := TDTManager.Create;
If FileExists(fMainFile) then
  Manager.LoadFromFile(fMainFile);
UpdateProjects;
If lbProjects.Count > 0 then
  lbProjects.ItemIndex := 0;
lbProjects.OnClick(Self);
actPrevItem.ShortCut := ShortCut(VK_TAB,[ssCtrl,ssShift]);
actNextItem.ShortCut := ShortCut(VK_TAB,[ssCtrl]);
end;

//------------------------------------------------------------------------------

procedure TfMainForm.FormDestroy(Sender: TObject);
begin
If fSaveOnClose then
  Manager.SaveToFile(fMainFile);
FreeAndNil(Manager);
end;

//------------------------------------------------------------------------------

procedure TfMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
frmProjectFrame.SaveFrame;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.lbProjectsClick(Sender: TObject);
begin
If lbProjects.ItemIndex >= 0 then
  frmProjectFrame.SetItem(Manager[lbProjects.ItemIndex])
else
  frmProjectFrame.SetItem(nil);
UpdateStatus;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.lbProjectsDblClick(Sender: TObject);
begin
If lbProjects.ItemIndex >= 0 then
  begin
    Manager[lbProjects.ItemIndex].Flagged := not Manager[lbProjects.ItemIndex].Flagged;
    lbProjects.Items[lbProjects.ItemIndex] := Manager[lbProjects.ItemIndex].FullName;
    frmProjectFrame.UpdateFlagged;
  end;
end;


//------------------------------------------------------------------------------

procedure TfMainForm.lbProjectsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Index:  Integer;
begin
If Button = mbRight then
  begin
    Index := lbProjects.ItemAtPos(Point(X,Y),True);
    If Index >= 0 then
      begin
        lbProjects.ItemIndex := Index;
        lbProjects.OnClick(Self);
      end;
  end;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.pmProjectsPopup(Sender: TObject);
begin
pmiProjects_Remove.Enabled := lbProjects.ItemIndex >= 0;
pmiProjects_RemoveAll.Enabled := Manager.Count > 0;
pmiProjects_FlagAll.Enabled := pmiProjects_RemoveAll.Enabled;
pmiProjects_UnflagAll.Enabled := pmiProjects_RemoveAll.Enabled;
pmiProjects_FlagToggle.Enabled := pmiProjects_RemoveAll.Enabled;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.pmiProjects_AddClick(Sender: TObject);
var
  Name:   String;
  Index:  Integer;
begin
Name := '';
If fProjectNameForm.Prompt('New project',Name) then
  begin
    Index := Manager.Add(Name);
    UpdateProjects;
    lbProjects.ItemIndex := Index;
    lbProjects.OnClick(Self);
  end;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.pmiProjects_RemoveClick(Sender: TObject);
var
  Index:  Integer;
begin
Index := lbProjects.ItemIndex;
If Manager[Index].DependentsCount > 0 then
  If MessageDlg(Format('Selected project (%s) has at least one dependent, are you sure to remove it?' + sLineBreak +
    '(note that it will be automatically removed from dependencies of all its dependents)',[Manager[Index].Name]),
    mtConfirmation,[mbYes,mbNo],0) <> mrYes then
    Exit;
If lbProjects.ItemIndex = Pred(lbProjects.Count) then
  lbProjects.ItemIndex := lbProjects.ItemIndex - 1
else
  lbProjects.ItemIndex := lbProjects.ItemIndex + 1;
lbProjects.OnClick(Self);
lbProjects.Items.Delete(Index);
Manager.Delete(Index);
frmProjectFrame.UpdateLists;
UpdateStatus;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.pmiProjects_RemoveAllClick(Sender: TObject);
begin
If MessageDlg('Are you sure to remove all projects?',mtWarning,[mbYes,mbNo],0) = mrYes then
  begin
    lbProjects.Clear;
    lbProjects.OnClick(Self);
    Manager.Clear;
    UpdateStatus;    
  end;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.pmiProjects_AddTemplateClick(Sender: TObject);
var
  Name:   String;
  Index:  Integer;
begin
Name := '';
If fProjectNameForm.Prompt('New project',Name) then
  begin
    Index := Manager.Add(Name);
    Manager[Index].RepositoryURL := Format(Manager.ProjectTemplate.RepositoryURL,[Name]);
    Manager[Index].ProjectDirector := Format(Manager.ProjectTemplate.ProjectDirectory,[Name]);
    UpdateProjects;
    lbProjects.ItemIndex := Index;
    lbProjects.OnClick(Self);
  end;
end;
//------------------------------------------------------------------------------

procedure TfMainForm.pmiProjects_TemplateSettingsClick(Sender: TObject);
begin
fTemplateSettingsForm.ShowModal;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.pmiProjects_List_CommaClick(Sender: TObject);
var
  FullName: Boolean;
  Text:     String;
  i:        Integer;
begin
FullName := self.pmiProjects_FullNames.Checked;
Text := '';
For i := Manager.LowIndex to Manager.HighIndex do
  begin
    If Length(Text) > 0 then
      Text := Text + ', ';
    If FullName then
      Text := Text + Manager[i].FullName
    else
      Text := Text + Manager[i].Name;
  end;
fTextEditForm.ShowTextReadOnly('Projects',Text,False);
end;

//------------------------------------------------------------------------------

procedure TfMainForm.pmiProjects_List_LineClick(Sender: TObject);
var
  FullName: Boolean;
  Text:     String;
  i:        Integer;
begin
FullName := self.pmiProjects_FullNames.Checked;
Text := '';
For i := Manager.LowIndex to Manager.HighIndex do
  begin
    If Length(Text) > 0 then
      Text := Text + sLineBreak;
    If FullName then
      Text := Text + Manager[i].FullName
    else
      Text := Text + Manager[i].Name;
  end;
fTextEditForm.ShowTextReadOnly('Projects',Text,False);
end;

//------------------------------------------------------------------------------

procedure TfMainForm.pmiProjects_FlagAllClick(Sender: TObject);
var
  i:  Integer;
begin
For i := Manager.LowIndex to Manager.HighIndex do
  Manager[i].Flagged := True;
UpdateProjects;
frmProjectFrame.UpdateFlagged;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.pmiProjects_UnflagAllClick(Sender: TObject);
var
  i:  Integer;
begin
For i := Manager.LowIndex to Manager.HighIndex do
  Manager[i].Flagged := False;
UpdateProjects;
frmProjectFrame.UpdateFlagged;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.pmiProjects_FlagToggleClick(Sender: TObject);
var
  i:  Integer;
begin
For i := Manager.LowIndex to Manager.HighIndex do
  Manager[i].Flagged := not Manager[i].Flagged;
UpdateProjects;
frmProjectFrame.UpdateFlagged;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.pmiProjects_FullNamesClick(Sender: TObject);
begin
pmiProjects_FullNames.Checked := not pmiProjects_FullNames.Checked;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.pmiProjects_SaveClick(Sender: TObject);
var
  OrigCursor: TCursor;
begin
OrigCursor := Screen.Cursor;
try
  Screen.Cursor := crHourGlass;
  frmProjectFrame.SaveFrame;
  Manager.SaveToFile(fMainFile);
finally
  Screen.Cursor := OrigCursor;
end;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.pmiProjects_ExitNSClick(Sender: TObject);
begin
If MessageDlg('Are you sure you want to exit the program without saving?',mtConfirmation,[mbYes,mbNo],0) = mrYes then
  begin
    fSaveOnClose := False;
    Close;
  end;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.pmiProjects_ExitClick(Sender: TObject);
begin
Close;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.eSearchForEnter(Sender: TObject);
begin
If eSearchFor.Tag = 0 then
  begin
    eSearchFor.Font.Color := clWindowText;
    eSearchFor.Text := '';
  end;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.eSearchForExit(Sender: TObject);
begin
If Length(eSearchFor.Text) <= 0 then
  begin
    eSearchFor.Font.Color := clGrayText;
    eSearchFor.Text := 'Search for...';
    eSearchFor.Tag := 0;
  end
else eSearchFor.Tag := 1;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.eSearchForKeyPress(Sender: TObject; var Key: Char);
begin
If Key = #13 then
  begin
    Key := #0;  
    btnFindNext.OnClick(Self);
  end;
end;
 
//------------------------------------------------------------------------------

procedure TfMainForm.btnFindPrevClick(Sender: TObject);
begin
actFindPrev.OnExecute(Self);
end;

//------------------------------------------------------------------------------

procedure TfMainForm.btnFindNextClick(Sender: TObject);
begin
actFindNext.OnExecute(Self);
end;

//------------------------------------------------------------------------------

procedure TfMainForm.actPrevItemExecute(Sender: TObject);
begin
If lbProjects.ItemIndex > 0 then
  begin
    lbProjects.ItemIndex := lbProjects.ItemIndex - 1;
    lbProjects.OnClick(nil);
  end;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.actNextItemExecute(Sender: TObject);
begin
If (lbProjects.Count > 0) and (lbProjects.ItemIndex < Pred(lbProjects.Count)) then
  begin
    lbProjects.ItemIndex := lbProjects.ItemIndex + 1;
    lbProjects.OnClick(nil);
  end;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.actFindExecute(Sender: TObject);
begin
eSearchFor.SetFocus;
end;
 
//------------------------------------------------------------------------------

procedure TfMainForm.actFindPrevExecute(Sender: TObject);
var
  Index:  Integer;
begin
If (eSearchFor.Font.Color <> clGrayText) and (lbProjects.ItemIndex >= 0) then
  begin
    Index := Manager.SearchBackward(eSearchFor.Text,lbProjects.ItemIndex);
    If Manager.CheckIndex(Index) then
      begin
        lbProjects.ItemIndex := Index;
        lbProjects.OnClick(Self);
      end
    else Beep;
  end
else Beep;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.actFindNextExecute(Sender: TObject);
var
  Index:  Integer;
begin
If (eSearchFor.Font.Color <> clGrayText) and (lbProjects.ItemIndex >= 0) then
  begin
    Index := Manager.SearchForward(eSearchFor.Text,lbProjects.ItemIndex);
    If Manager.CheckIndex(Index) then
      begin
        lbProjects.ItemIndex := Index;
        lbProjects.OnClick(Self);
      end
    else Beep;
  end
else Beep;
end;

end.
