object fTemplateSettingsForm: TfTemplateSettingsForm
  Left = 885
  Top = 587
  BorderStyle = bsDialog
  Caption = 'Template settings'
  ClientHeight = 142
  ClientWidth = 336
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
  object leRepositioryURL: TLabeledEdit
    Left = 8
    Top = 24
    Width = 321
    Height = 21
    EditLabel.Width = 190
    EditLabel.Height = 13
    EditLabel.Caption = 'Repositiory URL (%s for project name):'
    TabOrder = 0
  end
  object leProjectDirectory: TLabeledEdit
    Left = 8
    Top = 72
    Width = 294
    Height = 21
    EditLabel.Width = 190
    EditLabel.Height = 13
    EditLabel.Caption = 'Project directory (%s for project name)'
    TabOrder = 1
  end
  object btnOK: TButton
    Left = 176
    Top = 112
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 3
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 256
    Top = 112
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = btnCancelClick
  end
  object btnBrowseProjectDir: TButton
    Left = 303
    Top = 72
    Width = 25
    Height = 21
    Hint = 'Select project directory'
    Caption = '...'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    OnClick = btnBrowseProjectDirClick
  end
end
