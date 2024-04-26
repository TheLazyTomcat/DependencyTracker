{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit TemplateSettingsForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  DepsTracker_Manager;

type
  TfTemplateSettingsForm = class(TForm)
    leRepositioryURL: TLabeledEdit;
    leProjectDirectory: TLabeledEdit;
    btnBrowseProjectDir: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnBrowseProjectDirClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  protected
    fManager: TDTManager;
  public
    procedure Initialize(Manager: TDTManager);
  end;

var
  fTemplateSettingsForm: TfTemplateSettingsForm;

implementation

{$R *.dfm}

uses
  {$WARN UNIT_PLATFORM OFF}FileCtrl,{$WARN UNIT_PLATFORM ON}
  StrRect; 

procedure TfTemplateSettingsForm.Initialize(Manager: TDTManager);
begin
fManager := Manager;
end;

//==============================================================================

procedure TfTemplateSettingsForm.FormShow(Sender: TObject);
begin
leRepositioryURL.Text := fManager.ProjectTemplate.RepositoryURL;
leProjectDirectory.Text := fManager.ProjectTemplate.ProjectDirectory;
btnCancel.SetFocus;
end;

//------------------------------------------------------------------------------

procedure TfTemplateSettingsForm.btnBrowseProjectDirClick(Sender: TObject);
var
  DirPath:  String;
begin
If Length(leProjectDirectory.Text) > 0 then
  DirPath := leProjectDirectory.Text
else
  DirPath := ExtractFileDir(ParamStr(0));
If SelectDirectory(StrToWide('Select directory'),StrToWide(''),DirPath) then
  leProjectDirectory.Text := IncludeTrailingPathDelimiter(DirPath) + '%s';
end;

//------------------------------------------------------------------------------

procedure TfTemplateSettingsForm.btnOKClick(Sender: TObject);
var
  TempSettings: TDTPRojectTemplateSettings;
begin
try
  Format(leRepositioryURL.Text,['test']);
except
  on E: Exception do
    begin
      MessageDlg(Format('Error while testing repository URL (%s).',[E.Message]),mtError,[mbOK],0);
      leRepositioryURL.SetFocus;
      Exit;
    end;
end;
try
  Format(leProjectDirectory.Text,['test']);
except
  on E: Exception do
    begin
      MessageDlg(Format('Error while testing project directory (%s).',[E.Message]),mtError,[mbOK],0);
      leProjectDirectory.SetFocus;
      Exit;
    end;
end;
TempSettings.RepositoryURL := leRepositioryURL.Text;
TempSettings.ProjectDirectory := leProjectDirectory.Text;
fManager.ProjectTemplate := TempSettings;
Close;
end;

//------------------------------------------------------------------------------

procedure TfTemplateSettingsForm.btnCancelClick(Sender: TObject);
begin
Close;
end;

end.
