object fMainForm: TfMainForm
  Left = 308
  Top = 36
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Dependencies Tracker'
  ClientHeight = 642
  ClientWidth = 960
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lblProjects: TLabel
    Left = 8
    Top = 8
    Width = 43
    Height = 13
    Caption = 'Projects:'
  end
  object lbProjects: TListBox
    Left = 8
    Top = 24
    Width = 257
    Height = 592
    AutoComplete = False
    ExtendedSelect = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    IntegralHeight = True
    ItemHeight = 14
    ParentFont = False
    PopupMenu = pmProjects
    TabOrder = 0
    OnClick = lbProjectsClick
    OnMouseDown = lbProjectsMouseDown
  end
  object grbProjectDetails: TGroupBox
    Left = 272
    Top = 8
    Width = 681
    Height = 609
    Caption = 'Project details'
    TabOrder = 1
    inline frmProjectFrame: TfrmProjectFrame
      Left = 8
      Top = 16
      Width = 664
      Height = 586
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      inherited pnlBackgroundPanel: TPanel
        inherited lbDependents: TListBox [11]
        end
        inherited meConditionNotes: TMemo [12]
        end
        inherited lbDependencies: TListBox
          TabOrder = 8
        end
        inherited cbConditionDep: TCheckBox
          TabOrder = 7
        end
        inherited btnManageDeps: TButton
          TabOrder = 4
        end
        inherited btnDepReport: TButton
          TabOrder = 5
        end
        inherited btnDepTree: TButton
          TabOrder = 6
        end
      end
    end
  end
  object sbStatusBar: TStatusBar
    Left = 0
    Top = 623
    Width = 960
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Width = 100
      end
      item
        Alignment = taRightJustify
        Width = 300
      end>
  end
  object oXPManifest: TXPManifest
    Left = 920
  end
  object pmProjects: TPopupMenu
    OnPopup = pmProjectsPopup
    Left = 240
    object pmiProjects_Add: TMenuItem
      Caption = 'Add project...'
      ShortCut = 45
      OnClick = pmiProjects_AddClick
    end
    object pmiProjects_Remove: TMenuItem
      Caption = 'Remove selected project'
      ShortCut = 46
      OnClick = pmiProjects_RemoveClick
    end
    object pmiProjects_RemoveAll: TMenuItem
      Caption = 'Remove all projects'
      ShortCut = 8238
      OnClick = pmiProjects_RemoveAllClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object pmiProjects_List: TMenuItem
      Caption = 'Create listing'
      object pmiProjects_List_Comma: TMenuItem
        Caption = 'Comma separated...'
        OnClick = pmiProjects_List_CommaClick
      end
      object pmiProjects_List_Line: TMenuItem
        Caption = 'Line separated...'
        OnClick = pmiProjects_List_LineClick
      end
    end
    object pmiProjects_FullNames: TMenuItem
      Caption = 'Full names (option)'
      Checked = True
      OnClick = pmiProjects_FullNamesClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object pmiProjects_Save: TMenuItem
      Caption = 'Save now'
      ShortCut = 16467
      OnClick = pmiProjects_SaveClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object pmiProjects_ExitNS: TMenuItem
      Caption = 'Exit without saving'
      OnClick = pmiProjects_ExitNSClick
    end
    object pmiProjects_Exit: TMenuItem
      Caption = 'Exit'
      ShortCut = 16472
      OnClick = pmiProjects_ExitClick
    end
  end
end
