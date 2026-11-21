object frmInutilizacao: TfrmInutilizacao
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Inutiliza'#231#227'o de numera'#231#227'o'
  ClientHeight = 300
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object lcInutilizacao: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 500
    Height = 300
    Align = alClient
    TabOrder = 0
    object cbModelo: TcxComboBox
      Left = 24
      Top = 40
      Properties.DropDownListStyle = lsFixedList
      Properties.Items.Strings = (
        'NF-e (modelo 55)'
        'NFC-e (modelo 65)')
      Style.HotTrack = False
      TabOrder = 0
      Text = 'NF-e (modelo 55)'
      Width = 140
    end
    object edtSerie: TcxSpinEdit
      Left = 170
      Top = 40
      Properties.MaxValue = 889.000000000000000000
      Style.HotTrack = False
      TabOrder = 1
      Value = 1
      Width = 70
    end
    object edtNumeroInicial: TcxSpinEdit
      Left = 246
      Top = 40
      Properties.MaxValue = 999999999.000000000000000000
      Properties.MinValue = 1.000000000000000000
      Style.HotTrack = False
      TabOrder = 2
      Value = 1
      Width = 110
    end
    object edtNumeroFinal: TcxSpinEdit
      Left = 362
      Top = 40
      Properties.MaxValue = 999999999.000000000000000000
      Properties.MinValue = 1.000000000000000000
      Style.HotTrack = False
      TabOrder = 3
      Value = 1
      Width = 110
    end
    object memJustificativa: TcxMemo
      Left = 12
      Top = 100
      Properties.MaxLength = 255
      Properties.ScrollBars = ssVertical
      Style.HotTrack = False
      TabOrder = 4
      Height = 120
      Width = 476
    end
    object btnInutilizar: TcxButton
      Left = 282
      Top = 260
      Width = 100
      Height = 28
      Caption = 'Inutilizar'
      TabOrder = 5
      OnClick = btnInutilizarClick
    end
    object btnFechar: TcxButton
      Left = 388
      Top = 260
      Width = 100
      Height = 28
      Cancel = True
      Caption = 'Fechar'
      ModalResult = 2
      TabOrder = 6
    end
    object lcInutilizacaoGroup_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      Hidden = True
      ShowBorder = False
      Index = -1
    end
    object grpFaixa: TdxLayoutGroup
      Parent = lcInutilizacaoGroup_Root
      CaptionOptions.Text = 'Faixa a inutilizar'
      LayoutDirection = ldHorizontal
      Index = 0
    end
    object liModelo: TdxLayoutItem
      Parent = grpFaixa
      CaptionOptions.Text = 'Modelo'
      CaptionOptions.Layout = clTop
      Control = cbModelo
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 140
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liSerie: TdxLayoutItem
      Parent = grpFaixa
      CaptionOptions.Text = 'S'#233'rie'
      CaptionOptions.Layout = clTop
      Control = edtSerie
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 70
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liNumeroInicial: TdxLayoutItem
      Parent = grpFaixa
      CaptionOptions.Text = 'N'#250'mero inicial'
      CaptionOptions.Layout = clTop
      Control = edtNumeroInicial
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 110
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object liNumeroFinal: TdxLayoutItem
      Parent = grpFaixa
      CaptionOptions.Text = 'N'#250'mero final'
      CaptionOptions.Layout = clTop
      Control = edtNumeroFinal
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 110
      ControlOptions.ShowBorder = False
      Index = 3
    end
    object liJustificativa: TdxLayoutItem
      Parent = lcInutilizacaoGroup_Root
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'Justificativa (m'#237'nimo 15 caracteres)'
      CaptionOptions.Layout = clTop
      Control = memJustificativa
      ControlOptions.OriginalHeight = 120
      ControlOptions.OriginalWidth = 476
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object grpBotoes: TdxLayoutGroup
      Parent = lcInutilizacaoGroup_Root
      AlignHorz = ahRight
      CaptionOptions.Visible = False
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 2
    end
    object liInutilizar: TdxLayoutItem
      Parent = grpBotoes
      CaptionOptions.Visible = False
      Control = btnInutilizar
      ControlOptions.OriginalHeight = 28
      ControlOptions.OriginalWidth = 100
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liFechar: TdxLayoutItem
      Parent = grpBotoes
      CaptionOptions.Visible = False
      Control = btnFechar
      ControlOptions.OriginalHeight = 28
      ControlOptions.OriginalWidth = 100
      ControlOptions.ShowBorder = False
      Index = 1
    end
  end
end
