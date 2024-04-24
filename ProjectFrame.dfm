object frmProjectFrame: TfrmProjectFrame
  Left = 0
  Top = 0
  Width = 664
  Height = 586
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object pnlBackgroundPanel: TPanel
    Left = 0
    Top = 0
    Width = 664
    Height = 586
    Align = alClient
    BevelOuter = bvNone
    ParentBackground = True
    TabOrder = 0
    object lblType: TLabel
      Left = 0
      Top = 40
      Width = 28
      Height = 13
      Caption = 'Type:'
    end
    object lblNotes: TLabel
      Left = 0
      Top = 80
      Width = 32
      Height = 13
      Caption = 'Notes:'
    end
    object lblEditNotes: TLabel
      Left = 646
      Top = 75
      Width = 16
      Height = 19
      Hint = 'Open editor...'
      Caption = '2'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clTeal
      Font.Height = -16
      Font.Name = 'Webdings'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = lblEditNotesClick
      OnMouseEnter = lblEditNotesMouseEnter
      OnMouseLeave = lblEditNotesMouseLeave
    end
    object lblDependents: TLabel
      Left = 448
      Top = 328
      Width = 108
      Height = 13
      Caption = 'Dependents (indirect):'
    end
    object lblIndirectDeps: TLabel
      Left = 224
      Top = 328
      Width = 110
      Height = 13
      Caption = 'Indirect dependencies:'
    end
    object lblDependencies: TLabel
      Left = 0
      Top = 208
      Width = 71
      Height = 13
      Caption = 'Dependencies:'
    end
    object bvlSplitter: TBevel
      Left = 224
      Top = 314
      Width = 440
      Height = 9
      Shape = bsBottomLine
    end
    object shrNameBackground: TShape
      Left = 0
      Top = 0
      Width = 664
      Height = 33
      Pen.Style = psClear
    end
    object lblName: TLabel
      Left = 8
      Top = 0
      Width = 648
      Height = 33
      Alignment = taCenter
      AutoSize = False
      Caption = 'lblName'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
      Layout = tlCenter
      OnDblClick = lblNameDblClick
    end
    object lblEditCondNotes: TLabel
      Left = 648
      Top = 202
      Width = 16
      Height = 19
      Hint = 'Open editor...'
      Caption = '2'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clTeal
      Font.Height = -16
      Font.Name = 'Webdings'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = lblEditCondNotesClick
      OnMouseEnter = lblEditCondNotesMouseEnter
      OnMouseLeave = lblEditCondNotesMouseLeave
    end
    object meNotes: TMemo
      Left = 0
      Top = 96
      Width = 664
      Height = 105
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 3
      WordWrap = False
    end
    object meConditionNotes: TMemo
      Left = 224
      Top = 224
      Width = 440
      Height = 89
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 9
      WordWrap = False
    end
    object lbDependents: TListBox
      Left = 448
      Top = 344
      Width = 216
      Height = 242
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      IntegralHeight = True
      ItemHeight = 14
      ParentFont = False
      PopupMenu = pmListing
      TabOrder = 11
    end
    object lbIndirectDeps: TListBox
      Left = 224
      Top = 344
      Width = 217
      Height = 242
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      IntegralHeight = True
      ItemHeight = 14
      ParentFont = False
      PopupMenu = pmListing
      TabOrder = 10
    end
    object lbDependencies: TListBox
      Left = 0
      Top = 224
      Width = 217
      Height = 270
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      IntegralHeight = True
      ItemHeight = 14
      ParentFont = False
      PopupMenu = pmListing
      TabOrder = 4
      OnClick = lbDependenciesClick
      OnDblClick = lbDependenciesDblClick
    end
    object leRepositoryURL: TLabeledEdit
      Left = 184
      Top = 56
      Width = 455
      Height = 21
      EditLabel.Width = 78
      EditLabel.Height = 13
      EditLabel.Caption = 'Repository URL:'
      TabOrder = 1
    end
    object cbConditionDep: TCheckBox
      Left = 224
      Top = 206
      Width = 137
      Height = 17
      Caption = 'Conditional dependency'
      TabOrder = 8
      OnClick = cbConditionDepClick
    end
    object cbType: TComboBox
      Left = 0
      Top = 56
      Width = 177
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbTypeChange
    end
    object btnOpenRepURL: TButton
      Left = 639
      Top = 56
      Width = 25
      Height = 21
      Caption = '>'
      TabOrder = 2
      OnClick = btnOpenRepURLClick
    end
    object btnManageDeps: TButton
      Left = 0
      Top = 500
      Width = 217
      Height = 25
      Caption = 'Manage dependencies...'
      TabOrder = 5
      OnClick = btnManageDepsClick
    end
    object btnDepReport: TButton
      Left = 0
      Top = 530
      Width = 217
      Height = 25
      Caption = 'Dependency report...'
      Enabled = False
      TabOrder = 6
    end
    object btnDepTree: TButton
      Left = 0
      Top = 560
      Width = 217
      Height = 25
      Caption = 'Dependency tree...'
      Enabled = False
      TabOrder = 7
    end
  end
  object pmListing: TPopupMenu
    Left = 192
    Top = 200
    object pmiListing: TMenuItem
      Caption = 'Create listing'
      object pmiListing_Comma: TMenuItem
        Caption = 'Comma separated...'
        OnClick = pmiListing_CommaClick
      end
      object pmiListing_Line: TMenuItem
        Caption = 'Line separated...'
        OnClick = pmiListing_LineClick
      end
    end
  end
end
