object frmJustificativa: TfrmJustificativa
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Justificativa'
  ClientHeight = 260
  ClientWidth = 480
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 15
  object lcJustificativa: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 480
    Height = 260
    Align = alClient
    TabOrder = 0
    object lblInstrucao: TcxLabel
      Left = 12
      Top = 12
      Caption = 'Instru'#231#227'o'
      Properties.WordWrap = True
      Transparent = True
      Width = 456
    end
    object memTexto: TcxMemo
      Left = 12
      Top = 40
      Properties.MaxLength = 255
      Properties.ScrollBars = ssVertical
      Properties.OnChange = memTextoPropertiesChange
      Style.HotTrack = False
      TabOrder = 0
      Height = 140
      Width = 456
    end
    object lblContador: TcxLabel
      Left = 12
      Top = 186
      Caption = '0 caracteres'
      Transparent = True
    end
    object btnConfirmar: TcxButton
      Left = 262
      Top = 220
      Width = 100
      Height = 28
      Caption = 'Confirmar'
      Default = True
      TabOrder = 1
      OnClick = btnConfirmarClick
    end
    object btnCancelar: TcxButton
      Left = 368
      Top = 220
      Width = 100
      Height = 28
      Cancel = True
      Caption = 'Cancelar'
      ModalResult = 2
      TabOrder = 2
    end
    object lcJustificativaGroup_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      Hidden = True
      ShowBorder = False
      Index = -1
    end
    object liInstrucao: TdxLayoutItem
      Parent = lcJustificativaGroup_Root
      AlignHorz = ahClient
      CaptionOptions.Visible = False
      Control = lblInstrucao
      ControlOptions.OriginalHeight = 30
      ControlOptions.OriginalWidth = 456
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liTexto: TdxLayoutItem
      Parent = lcJustificativaGroup_Root
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Visible = False
      Control = memTexto
      ControlOptions.OriginalHeight = 140
      ControlOptions.OriginalWidth = 456
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liContador: TdxLayoutItem
      Parent = lcJustificativaGroup_Root
      CaptionOptions.Visible = False
      Control = lblContador
      ControlOptions.OriginalHeight = 19
      ControlOptions.OriginalWidth = 200
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object grpBotoes: TdxLayoutGroup
      Parent = lcJustificativaGroup_Root
      AlignHorz = ahRight
      CaptionOptions.Visible = False
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 3
    end
    object liConfirmar: TdxLayoutItem
      Parent = grpBotoes
      CaptionOptions.Visible = False
      Control = btnConfirmar
      ControlOptions.OriginalHeight = 28
      ControlOptions.OriginalWidth = 100
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liCancelar: TdxLayoutItem
      Parent = grpBotoes
      CaptionOptions.Visible = False
      Control = btnCancelar
      ControlOptions.OriginalHeight = 28
      ControlOptions.OriginalWidth = 100
      ControlOptions.ShowBorder = False
      Index = 1
    end
  end
end
