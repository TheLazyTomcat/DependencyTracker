object fTextEditForm: TfTextEditForm
  Left = 314
  Top = 164
  Width = 870
  Height = 500
  BorderStyle = bsSizeToolWin
  Caption = 'Text edit'
  Color = clBtnFace
  Constraints.MinHeight = 256
  Constraints.MinWidth = 512
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  DesignSize = (
    862
    466)
  PixelsPerInch = 96
  TextHeight = 13
  object meText: TMemo
    Left = 8
    Top = 8
    Width = 849
    Height = 449
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
    OnKeyPress = meTextKeyPress
  end
end
