program DependencyTracker;

uses
  Forms,
  MainForm in 'MainForm.pas' {fMainForm},
  DepsTracker_Common in 'Source\DepsTracker_Common.pas',
  DepsTracker_Project in 'Source\DepsTracker_Project.pas',
  DepsTracker_Manager in 'Source\DepsTracker_Manager.pas',
  ProjectNameForm in 'ProjectNameForm.pas' {fProjectNameForm},
  ProjectFrame in 'ProjectFrame.pas' {frmProjectFrame: TFrame},
  TextEditForm in 'TextEditForm.pas' {fTextEditForm},
  ProjectsSelectForm in 'ProjectsSelectForm.pas' {fProjectsSelect};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Dependency Tracker';
  Application.CreateForm(TfMainForm, fMainForm);
  Application.CreateForm(TfProjectNameForm, fProjectNameForm);
  Application.CreateForm(TfTextEditForm, fTextEditForm);
  Application.CreateForm(TfProjectsSelect, fProjectsSelect);
  fProjectNameForm.Initialize(fMainForm.Manager);
  fProjectsSelect.Initialize(fMainForm.Manager);
  Application.Run;
end.
