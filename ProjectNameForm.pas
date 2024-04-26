{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ProjectNameForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  DepsTracker_Manager;

type
  TfProjectNameForm = class(TForm)
    leProjectName: TLabeledEdit;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormShow(Sender: TObject);    
    procedure leProjectNameKeyPress(Sender: TObject; var Key: Char);
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
    Function Prompt(const Caption: String; var Name: String): Boolean;
  end;

var
  fProjectNameForm: TfProjectNameForm;

implementation

{$R *.dfm}

procedure TfProjectNameForm.Initialize(Manager: TDTManager);
begin
fManager := Manager;
end;

//------------------------------------------------------------------------------

Function TfProjectNameForm.Prompt(const Caption: String; var Name: String): Boolean;
begin
Self.Caption := Caption;
leProjectName.Text := Name;
fAccepted := False;
ShowModal;
Name := leProjectName.Text;
Result := fAccepted;
end;

//==============================================================================

procedure TfProjectNameForm.FormShow(Sender: TObject);
begin
If Length(leProjectName.Text) > 0 then
  leProjectName.SelectAll;
leProjectName.SetFocus;
end;

//------------------------------------------------------------------------------

procedure TfProjectNameForm.leProjectNameKeyPress(Sender: TObject;
  var Key: Char);
begin
If Key = #13 then
  begin
    Key := #0;
    btnOK.OnClick(Self);
  end
else If Key = #27 then
  begin
    Key := #0;
    btnCancel.OnClick(Self);
  end;
end;

//------------------------------------------------------------------------------

procedure TfProjectNameForm.btnOKClick(Sender: TObject);

  procedure InvalidName(const Text: String);
  begin
    MessageDlg(Text,mtError,[mbOk],0);
    leProjectName.SetFocus;
  end;

var
  Idx:  Integer;
begin
If Length(leProjectName.Text) > 0 then
  begin
    If not fManager.Find(leProjectName.Text,Idx) then
      begin
        fAccepted := True;
        Close;
      end
    else InvalidName('Project of this name already exists.')
  end
else InvalidName('Project name cannot be an empty string.');
end;

//------------------------------------------------------------------------------

procedure TfProjectNameForm.btnCancelClick(Sender: TObject);
begin
Close;
end;

end.
