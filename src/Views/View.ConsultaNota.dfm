object frmConsultaNota: TfrmConsultaNota
  Left = 0
  Top = 0
  Caption = 'Notas emitidas'
  ClientHeight = 600
  ClientWidth = 1100
  Color = clBtnFace
  Constraints.MinHeight = 520
  Constraints.MinWidth = 960
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 15
  object lcConsulta: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 1100
    Height = 600
    Align = alClient
    TabOrder = 0
    object edtDataInicial: TcxDateEdit
      Left = 24
      Top = 50
      Style.HotTrack = False
      TabOrder = 0
      Width = 110
    end
    object edtDataFinal: TcxDateEdit
      Left = 140
      Top = 50
      Style.HotTrack = False
      TabOrder = 1
      Width = 110
    end
    object cbModelo: TcxComboBox
      Left = 256
      Top = 50
      Properties.DropDownListStyle = lsFixedList
      Properties.Items.Strings = (
        'Todos'
        'NF-e (55)'
        'NFC-e (65)')
      Style.HotTrack = False
      TabOrder = 2
      Width = 110
    end
    object cbStatus: TcxComboBox
      Left = 372
      Top = 50
      Properties.DropDownListStyle = lsFixedList
      Style.HotTrack = False
      TabOrder = 3
      Width = 170
    end
    object edtTexto: TcxTextEdit
      Left = 548
      Top = 50
      Style.HotTrack = False
      TabOrder = 4
      TextHint = 'N'#250'mero, chave ou cliente'
      OnKeyDown = edtTextoKeyDown
      Width = 300
    end
    object btnPesquisar: TcxButton
      Left = 960
      Top = 48
      Width = 100
      Height = 26
      Caption = 'Pesquisar'
      TabOrder = 5
      OnClick = btnPesquisarClick
    end
    object grdNotas: TcxGrid
      Left = 12
      Top = 100
      Width = 1076
      Height = 440
      TabOrder = 6
      object tvNotas: TcxGridTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        OptionsView.NoDataToDisplayInfoText = '<Nenhum registro>'
        object tvNotasId: TcxGridColumn
          DataBinding.ValueType = 'Integer'
          Visible = False
        end
        object tvNotasData: TcxGridColumn
          Caption = 'Emiss'#227'o'
          DataBinding.ValueType = 'DateTime'
          Width = 120
        end
        object tvNotasModelo: TcxGridColumn
          Caption = 'Modelo'
          Width = 55
        end
        object tvNotasSerie: TcxGridColumn
          Caption = 'S'#233'rie'
          DataBinding.ValueType = 'Integer'
          Width = 45
        end
        object tvNotasNumero: TcxGridColumn
          Caption = 'N'#250'mero'
          DataBinding.ValueType = 'Integer'
          Width = 70
        end
        object tvNotasCliente: TcxGridColumn
          Caption = 'Cliente'
          Width = 200
        end
        object tvNotasTotal: TcxGridColumn
          Caption = 'Total'
          DataBinding.ValueType = 'Currency'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;-,0.00'
          HeaderAlignmentHorz = taRightJustify
          Width = 90
        end
        object tvNotasSituacao: TcxGridColumn
          Caption = 'Situa'#231#227'o'
          Width = 140
        end
        object tvNotasChave: TcxGridColumn
          Caption = 'Chave de acesso'
          Width = 300
        end
        object tvNotasMotivo: TcxGridColumn
          Caption = 'Retorno SEFAZ'
          Width = 250
        end
      end
      object lvNotas: TcxGridLevel
        GridView = tvNotas
      end
    end
    object btnImprimir: TcxButton
      Left = 12
      Top = 560
      Width = 100
      Height = 28
      Caption = 'Imprimir'
      TabOrder = 7
      OnClick = btnImprimirClick
    end
    object btnPdf: TcxButton
      Left = 118
      Top = 560
      Width = 100
      Height = 28
      Caption = 'PDF'
      TabOrder = 8
      OnClick = btnPdfClick
    end
    object btnEmail: TcxButton
      Left = 224
      Top = 560
      Width = 100
      Height = 28
      Caption = 'E-mail'
      TabOrder = 9
      OnClick = btnEmailClick
    end
    object btnXml: TcxButton
      Left = 330
      Top = 560
      Width = 100
      Height = 28
      Caption = 'Exportar XML'
      TabOrder = 10
      OnClick = btnXmlClick
    end
    object btnCancelar: TcxButton
      Left = 436
      Top = 560
      Width = 110
      Height = 28
      Caption = 'Cancelar nota'
      TabOrder = 11
      OnClick = btnCancelarClick
    end
    object btnCCe: TcxButton
      Left = 552
      Top = 560
      Width = 120
      Height = 28
      Caption = 'Carta de corre'#231#227'o'
      TabOrder = 12
      OnClick = btnCCeClick
    end
    object btnTransmitir: TcxButton
      Left = 678
      Top = 560
      Width = 170
      Height = 28
      Caption = 'Transmitir conting'#234'ncia'
      TabOrder = 13
      OnClick = btnTransmitirClick
    end
    object btnFechar: TcxButton
      Left = 988
      Top = 560
      Width = 100
      Height = 28
      Cancel = True
      Caption = 'Fechar'
      ModalResult = 2
      TabOrder = 14
    end
    object lcConsultaGroup_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      Hidden = True
      ShowBorder = False
      Index = -1
    end
    object grpFiltro: TdxLayoutGroup
      Parent = lcConsultaGroup_Root
      CaptionOptions.Text = 'Filtro'
      LayoutDirection = ldHorizontal
      Index = 0
    end
    object liDataInicial: TdxLayoutItem
      Parent = grpFiltro
      CaptionOptions.Text = 'De'
      CaptionOptions.Layout = clTop
      Control = edtDataInicial
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 110
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liDataFinal: TdxLayoutItem
      Parent = grpFiltro
      CaptionOptions.Text = 'At'#233
      CaptionOptions.Layout = clTop
      Control = edtDataFinal
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 110
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liModelo: TdxLayoutItem
      Parent = grpFiltro
      CaptionOptions.Text = 'Modelo'
      CaptionOptions.Layout = clTop
      Control = cbModelo
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 110
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object liStatus: TdxLayoutItem
      Parent = grpFiltro
      CaptionOptions.Text = 'Situa'#231#227'o'
      CaptionOptions.Layout = clTop
      Control = cbStatus
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 170
      ControlOptions.ShowBorder = False
      Index = 3
    end
    object liTexto: TdxLayoutItem
      Parent = grpFiltro
      AlignHorz = ahClient
      CaptionOptions.Text = 'Pesquisar'
      CaptionOptions.Layout = clTop
      Control = edtTexto
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 300
      ControlOptions.ShowBorder = False
      Index = 4
    end
    object liPesquisar: TdxLayoutItem
      Parent = grpFiltro
      AlignVert = avBottom
      CaptionOptions.Visible = False
      Control = btnPesquisar
      ControlOptions.OriginalHeight = 26
      ControlOptions.OriginalWidth = 100
      ControlOptions.ShowBorder = False
      Index = 5
    end
    object liNotas: TdxLayoutItem
      Parent = lcConsultaGroup_Root
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Visible = False
      Control = grdNotas
      ControlOptions.OriginalHeight = 440
      ControlOptions.OriginalWidth = 1076
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object grpAcoes: TdxLayoutGroup
      Parent = lcConsultaGroup_Root
      CaptionOptions.Visible = False
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 2
    end
    object liImprimir: TdxLayoutItem
      Parent = grpAcoes
      CaptionOptions.Visible = False
      Control = btnImprimir
      ControlOptions.OriginalHeight = 28
      ControlOptions.OriginalWidth = 100
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liPdf: TdxLayoutItem
      Parent = grpAcoes
      CaptionOptions.Visible = False
      Control = btnPdf
      ControlOptions.OriginalHeight = 28
      ControlOptions.OriginalWidth = 100
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liEmail: TdxLayoutItem
      Parent = grpAcoes
      CaptionOptions.Visible = False
      Control = btnEmail
      ControlOptions.OriginalHeight = 28
      ControlOptions.OriginalWidth = 100
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object liXml: TdxLayoutItem
      Parent = grpAcoes
      CaptionOptions.Visible = False
      Control = btnXml
      ControlOptions.OriginalHeight = 28
      ControlOptions.OriginalWidth = 100
      ControlOptions.ShowBorder = False
      Index = 3
    end
    object liCancelar: TdxLayoutItem
      Parent = grpAcoes
      CaptionOptions.Visible = False
      Control = btnCancelar
      ControlOptions.OriginalHeight = 28
      ControlOptions.OriginalWidth = 110
      ControlOptions.ShowBorder = False
      Index = 4
    end
    object liCCe: TdxLayoutItem
      Parent = grpAcoes
      CaptionOptions.Visible = False
      Control = btnCCe
      ControlOptions.OriginalHeight = 28
      ControlOptions.OriginalWidth = 120
      ControlOptions.ShowBorder = False
      Index = 5
    end
    object liTransmitir: TdxLayoutItem
      Parent = grpAcoes
      CaptionOptions.Visible = False
      Control = btnTransmitir
      ControlOptions.OriginalHeight = 28
      ControlOptions.OriginalWidth = 170
      ControlOptions.ShowBorder = False
      Index = 6
    end
    object liFechar: TdxLayoutItem
      Parent = grpAcoes
      AlignHorz = ahRight
      CaptionOptions.Visible = False
      Control = btnFechar
      ControlOptions.OriginalHeight = 28
      ControlOptions.OriginalWidth = 100
      ControlOptions.ShowBorder = False
      Index = 7
    end
  end
end
