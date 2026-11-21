object frmFormaPagamento: TfrmFormaPagamento
  Left = 0
  Top = 0
  Caption = 'Formas de pagamento'
  ClientHeight = 440
  ClientWidth = 560
  Color = clBtnFace
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
  object lcForma: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 560
    Height = 440
    Align = alClient
    TabOrder = 0
    object grdFormas: TcxGrid
      Left = 12
      Top = 12
      Width = 536
      Height = 240
      TabOrder = 0
      object tvFormas: TcxGridTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        OnFocusedRecordChanged = tvFormasFocusedRecordChanged
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
        object tvFormasId: TcxGridColumn
          DataBinding.ValueType = 'Integer'
          Visible = False
        end
        object tvFormasDescricao: TcxGridColumn
          Caption = 'Descri'#231#227'o'
          Width = 260
        end
        object tvFormasCodigo: TcxGridColumn
          Caption = 'C'#243'digo SEFAZ'
          Width = 100
        end
        object tvFormasAtivo: TcxGridColumn
          Caption = 'Ativa'
          Width = 60
        end
      end
      object lvFormas: TcxGridLevel
        GridView = tvFormas
      end
    end
    object edtDescricao: TcxTextEdit
      Left = 24
      Top = 300
      Properties.MaxLength = 60
      Style.HotTrack = False
      TabOrder = 1
      Width = 220
    end
    object cbCodigoSefaz: TcxComboBox
      Left = 250
      Top = 300
      Properties.DropDownListStyle = lsFixedList
      Properties.DropDownRows = 12
      Style.HotTrack = False
      TabOrder = 2
      Width = 180
    end
    object chkAtivo: TcxCheckBox
      Left = 440
      Top = 300
      Caption = 'Ativa'
      State = cbsChecked
      Style.HotTrack = False
      TabOrder = 3
    end
    object btnNovo: TcxButton
      Left = 230
      Top = 400
      Width = 100
      Height = 28
      Caption = 'Novo'
      TabOrder = 4
      OnClick = btnNovoClick
    end
    object btnSalvar: TcxButton
      Left = 336
      Top = 400
      Width = 100
      Height = 28
      Caption = 'Salvar'
      TabOrder = 5
      OnClick = btnSalvarClick
    end
    object btnFechar: TcxButton
      Left = 442
      Top = 400
      Width = 100
      Height = 28
      Cancel = True
      Caption = 'Fechar'
      ModalResult = 2
      TabOrder = 6
    end
    object lcFormaGroup_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      Hidden = True
      ShowBorder = False
      Index = -1
    end
    object liFormas: TdxLayoutItem
      Parent = lcFormaGroup_Root
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Visible = False
      Control = grdFormas
      ControlOptions.OriginalHeight = 240
      ControlOptions.OriginalWidth = 536
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object grpEdicao: TdxLayoutGroup
      Parent = lcFormaGroup_Root
      CaptionOptions.Text = 'Forma de pagamento'
      LayoutDirection = ldHorizontal
      Index = 1
    end
    object liDescricao: TdxLayoutItem
      Parent = grpEdicao
      AlignHorz = ahClient
      CaptionOptions.Text = 'Descri'#231#227'o'
      CaptionOptions.Layout = clTop
      Control = edtDescricao
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 220
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liCodigoSefaz: TdxLayoutItem
      Parent = grpEdicao
      CaptionOptions.Text = 'C'#243'digo SEFAZ (tPag)'
      CaptionOptions.Layout = clTop
      Control = cbCodigoSefaz
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 180
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liAtivo: TdxLayoutItem
      Parent = grpEdicao
      AlignVert = avBottom
      CaptionOptions.Visible = False
      Control = chkAtivo
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 70
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object grpBotoes: TdxLayoutGroup
      Parent = lcFormaGroup_Root
      AlignHorz = ahRight
      CaptionOptions.Visible = False
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 2
    end
    object liNovo: TdxLayoutItem
      Parent = grpBotoes
      CaptionOptions.Visible = False
      Control = btnNovo
      ControlOptions.OriginalHeight = 28
      ControlOptions.OriginalWidth = 100
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liSalvar: TdxLayoutItem
      Parent = grpBotoes
      CaptionOptions.Visible = False
      Control = btnSalvar
      ControlOptions.OriginalHeight = 28
      ControlOptions.OriginalWidth = 100
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liFechar: TdxLayoutItem
      Parent = grpBotoes
      CaptionOptions.Visible = False
      Control = btnFechar
      ControlOptions.OriginalHeight = 28
      ControlOptions.OriginalWidth = 100
      ControlOptions.ShowBorder = False
      Index = 2
    end
  end
end
