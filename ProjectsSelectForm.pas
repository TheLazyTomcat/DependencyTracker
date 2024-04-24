unit ProjectsSelectForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst,
  DepsTracker_Common, DepsTracker_Project, DepsTracker_Manager;

type
  TfProjectsSelect = class(TForm)
    clbProjects: TCheckListBox;
    btnOK: TButton;
    btnCancel: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  protected
    fAccepted:  Boolean;
    fManager:   TDTManager;
  public
    { Public declarations }
    procedure Initialize(Manager: TDTManager);
    Function SelectDependencies(Project: TDTProject; var Dependencies: TDTProjectArray): Boolean;
  end;

var
  fProjectsSelect: TfProjectsSelect;

implementation

{$R *.dfm}

procedure TfProjectsSelect.Initialize(Manager: TDTManager);
begin
fManager:= Manager;
end;

//------------------------------------------------------------------------------

Function TfProjectsSelect.SelectDependencies(Project: TDTProject; var Dependencies: TDTProjectArray): Boolean;
var
  i,Cnt,Idx:  Integer;
begin
// prepare list
while clbProjects.Count < fManager.Count do
  clbProjects.Items.Add('');
while clbProjects.Count > fManager.Count do
  clbProjects.Items.Delete(Pred(clbProjects.Count));
For i := fManager.LowIndex to fManager.HighIndex do
  begin
    clbProjects.Items.Strings[i] := fManager[i].Name;
    clbProjects.Items.Objects[i] := fManager[i];
    clbProjects.Checked[i] := False;
  end;
For i := Low(Dependencies) to High(Dependencies) do
  clbProjects.Checked[Dependencies[i].Index] := True;
clbProjects.Items.Delete(Project.Index);
fAccepted := False;
// show form...
ShowModal;
// build result
If fAccepted then
  begin
    Cnt := 0;
    For i := 0 to Pred(clbProjects.Count) do
      If clbProjects.Checked[i] then
        Inc(Cnt);
    SetLength(Dependencies,Cnt);
    Idx := 0;
    For i := 0 to Pred(clbProjects.Count) do
      If clbProjects.Checked[i] then
        begin
          Dependencies[Idx] := clbProjects.Items.Objects[i] as TDTProject;
          Inc(Idx);
        end;
  end
else SetLength(Dependencies,0);
Result := fAccepted;
end;

//==============================================================================

procedure TfProjectsSelect.btnOKClick(Sender: TObject);
begin
fAccepted := True;
Close;
end;

//------------------------------------------------------------------------------

procedure TfProjectsSelect.btnCancelClick(Sender: TObject);
begin
Close;
end;

end.
