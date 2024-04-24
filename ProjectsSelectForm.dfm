object fProjectsSelect: TfProjectsSelect
  Left = 1010
  Top = 375
  BorderStyle = bsDialog
  Caption = 'Select projects'
  ClientHeight = 344
  ClientWidth = 257
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object clbProjects: TCheckListBox
    Left = 8
    Top = 8
    Width = 241
    Height = 298
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    IntegralHeight = True
    ItemHeight = 14
    ParentFont = False
    TabOrder = 0
  end
  object btnOK: TButton
    Left = 96
    Top = 312
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 176
    Top = 312
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = btnCancelClick
  end
end
