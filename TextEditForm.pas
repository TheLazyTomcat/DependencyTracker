{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit TextEditForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfTextEditForm = class(TForm)
    meText: TMemo;
    procedure meTextKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ShowTextEditor(const Title: String; var Text: String; ProportionalFont: Boolean);
    procedure ShowTextReadOnly(const Title: String; var Text: String; ProportionalFont: Boolean);
  end;

var
  fTextEditForm: TfTextEditForm;

implementation   

{$R *.dfm}

procedure TfTextEditForm.ShowTextEditor(const Title: String; var Text: String; ProportionalFont: Boolean);
begin
Caption := Title;
If ProportionalFont then
  meText.Font.Name := 'Tahoma'
else
  meText.Font.Name := 'Courier New';
meText.Text := Text;
// set cursor at the end of text
If Length(meText.Text) > 0 then
  meText.SelStart := Length(meText.Text);
ShowModal;
Text := meText.Text;
end;

//------------------------------------------------------------------------------

procedure TfTextEditForm.ShowTextReadOnly(const Title: String; var Text: String; ProportionalFont: Boolean);
begin
meText.ReadOnly := True;
try
  ShowTextEditor(Title,Text,ProportionalFont);
finally
  meText.ReadOnly := False;
end;
end;

//------------------------------------------------------------------------------

procedure TfTextEditForm.meTextKeyPress(Sender: TObject; var Key: Char);
begin
case Key of
  ^A:   begin
          meText.SelectAll;
          Key := #0;
        end;
  #27:  Close;  // escape
end;
end;

end.
