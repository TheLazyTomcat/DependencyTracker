unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, XPMan, Menus, ProjectFrame, ComCtrls,
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
    pmiProjects_List: TMenuItem;
    pmiProjects_FullNames: TMenuItem;
    pmiProjects_List_Comma: TMenuItem;
    pmiProjects_List_Line: TMenuItem;
    N2: TMenuItem;
    pmiProjects_Save: TMenuItem;
    N3: TMenuItem;
    pmiProjects_ExitNS: TMenuItem;
    pmiProjects_Exit: TMenuItem;
    grbProjectDetails: TGroupBox;
    frmProjectFrame: TfrmProjectFrame;
    oXPManifest: TXPManifest;
    sbStatusBar: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbProjectsClick(Sender: TObject);
    procedure lbProjectsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pmProjectsPopup(Sender: TObject);
    procedure pmiProjects_AddClick(Sender: TObject);
    procedure pmiProjects_RemoveClick(Sender: TObject);
    procedure pmiProjects_RemoveAllClick(Sender: TObject);
    procedure pmiProjects_List_CommaClick(Sender: TObject);
    procedure pmiProjects_List_LineClick(Sender: TObject);
    procedure pmiProjects_SaveClick(Sender: TObject);
    procedure pmiProjects_ExitNSClick(Sender: TObject);
    procedure pmiProjects_ExitClick(Sender: TObject);
    procedure pmiProjects_FullNamesClick(Sender: TObject);
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
  ProjectNameForm, TextEditForm;

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
frmProjectFrame.Initialize;
frmProjectFrame.OnListChange := ListChangeHandler;
frmProjectFrame.OnListSelect := ListSelectHandler;
fSaveOnClose := True;
fMainFile := ExtractFilePath(ParamStr(0)) + 'depstrack.dat';
sbStatusBar.Panels[1].Text := fMainFile;
Manager := TDTManager.Create;
If FileExists(fMainFile) then
  Manager.LoadFromFile(fMainFile);
UpdateProjects;
If lbProjects.Count > 0 then
  lbProjects.ItemIndex := 0;
lbProjects.OnClick(Self);
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
        lbProjects.OnClick(nil);
      end;
  end;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.pmProjectsPopup(Sender: TObject);
begin
pmiProjects_Remove.Enabled := lbProjects.ItemIndex >= 0;
pmiProjects_RemoveAll.Enabled := Manager.Count > 0;
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

end.
