object fProjectNameForm: TfProjectNameForm
  Left = 976
  Top = 621
  BorderStyle = bsDialog
  Caption = 'fProjectNameForm'
  ClientHeight = 88
  ClientWidth = 280
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object leProjectName: TLabeledEdit
    Left = 8
    Top = 24
    Width = 265
    Height = 21
    EditLabel.Width = 67
    EditLabel.Height = 13
    EditLabel.Caption = 'Project name:'
    TabOrder = 0
    OnKeyPress = leProjectNameKeyPress
  end
  object btnOK: TButton
    Left = 120
    Top = 56
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 200
    Top = 56
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = btnCancelClick
  end
end
