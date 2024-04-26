{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
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
  ProjectsSelectForm in 'ProjectsSelectForm.pas' {fProjectsSelectForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Dependency Tracker';
  Application.CreateForm(TfMainForm, fMainForm);
  Application.CreateForm(TfProjectNameForm, fProjectNameForm);
  Application.CreateForm(TfTextEditForm, fTextEditForm);
  Application.CreateForm(TfProjectsSelectForm, fProjectsSelectForm);
  fProjectNameForm.Initialize(fMainForm.Manager);
  fProjectsSelectForm.Initialize(fMainForm.Manager);
  Application.Run;
end.
