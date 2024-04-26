{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ProjectsSelectForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst,
  DepsTracker_Common, DepsTracker_Project, DepsTracker_Manager;

type
  TfProjectsSelectForm = class(TForm)
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
  fProjectsSelectForm: TfProjectsSelectForm;

implementation

{$R *.dfm}

procedure TfProjectsSelectForm.Initialize(Manager: TDTManager);
begin
fManager:= Manager;
end;

//------------------------------------------------------------------------------

Function TfProjectsSelectForm.SelectDependencies(Project: TDTProject; var Dependencies: TDTProjectArray): Boolean;
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

procedure TfProjectsSelectForm.btnOKClick(Sender: TObject);
begin
fAccepted := True;
Close;
end;

//------------------------------------------------------------------------------

procedure TfProjectsSelectForm.btnCancelClick(Sender: TObject);
begin
Close;
end;

end.
