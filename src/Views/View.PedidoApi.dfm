object frmPedidoApi: TfrmPedidoApi
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Importar pedido da API'
  ClientHeight = 460
  ClientWidth = 760
  Color = clBtnFace
  Constraints.MinHeight = 360
  Constraints.MinWidth = 640
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnDestroy = FormDestroy
  TextHeight = 15
  object lcPedidos: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 760
    Height = 460
    Align = alClient
    TabOrder = 0
    object lblInstrucao: TcxLabel
      Left = 12
      Top = 12
      Caption =
        'Pedidos da delphi-horse-api. Escolha um pedido em aberto para fa' +
        'turar como NF-e.'
      Properties.WordWrap = True
      Transparent = True
      Width = 736
    end
    object grdPedidos: TcxGrid
      Left = 12
      Top = 38
      Width = 736
      Height = 330
      TabOrder = 0
      object tvPedidos: TcxGridTableView
        OnDblClick = tvPedidosDblClick
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        OnFocusedRecordChanged = tvPedidosFocusedRecordChanged
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsCustomize.ColumnFiltering = False
        OptionsCustomize.ColumnGrouping = False
        OptionsCustomize.ColumnSorting = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        OptionsView.NoDataToDisplayInfoText = '<Nenhum pedido na API>'
        object tvPedidosNumero: TcxGridColumn
          Caption = 'N'#186
          DataBinding.ValueType = 'Integer'
          PropertiesClassName = 'TcxTextEditProperties'
          Properties.Alignment.Horz = taRightJustify
          HeaderAlignmentHorz = taRightJustify
          Width = 55
        end
        object tvPedidosData: TcxGridColumn
          Caption = 'Data'
          Width = 120
        end
        object tvPedidosCliente: TcxGridColumn
          Caption = 'Cliente'
          Width = 250
        end
        object tvPedidosTotal: TcxGridColumn
          Caption = 'Total'
          DataBinding.ValueType = 'Currency'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.Alignment.Horz = taRightJustify
          Properties.DisplayFormat = ',0.00'
          HeaderAlignmentHorz = taRightJustify
          Width = 100
        end
        object tvPedidosStatus: TcxGridColumn
          Caption = 'Status'
          Width = 90
        end
        object tvPedidosNota: TcxGridColumn
          Caption = 'Faturado'
          Width = 100
        end
      end
      object lvPedidos: TcxGridLevel
        GridView = tvPedidos
      end
    end
    object lblMotivo: TcxLabel
      Left = 12
      Top = 374
      Style.TextColor = clMaroon
      Transparent = True
    end
    object btnAnterior: TcxButton
      Left = 12
      Top = 420
      Width = 90
      Height = 28
      Caption = '< Anterior'
      TabOrder = 1
      OnClick = btnAnteriorClick
    end
    object lblPagina: TcxLabel
      Left = 108
      Top = 425
      Caption = 'P'#225'gina 1 de 1'
      Transparent = True
    end
    object btnProxima: TcxButton
      Left = 290
      Top = 420
      Width = 90
      Height = 28
      Caption = 'Pr'#243'xima >'
      TabOrder = 2
      OnClick = btnProximaClick
    end
    object btnEscolher: TcxButton
      Left = 542
      Top = 420
      Width = 100
      Height = 28
      Caption = 'Importar'
      Default = True
      TabOrder = 3
      OnClick = btnEscolherClick
    end
    object btnCancelar: TcxButton
      Left = 648
      Top = 420
      Width = 100
      Height = 28
      Cancel = True
      Caption = 'Cancelar'
      ModalResult = 2
      TabOrder = 4
    end
    object lcPedidosGroup_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      Hidden = True
      ShowBorder = False
      Index = -1
    end
    object liInstrucao: TdxLayoutItem
      Parent = lcPedidosGroup_Root
      AlignHorz = ahClient
      CaptionOptions.Visible = False
      Control = lblInstrucao
      ControlOptions.OriginalHeight = 20
      ControlOptions.OriginalWidth = 736
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liPedidos: TdxLayoutItem
      Parent = lcPedidosGroup_Root
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Visible = False
      Control = grdPedidos
      ControlOptions.OriginalHeight = 330
      ControlOptions.OriginalWidth = 736
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liMotivo: TdxLayoutItem
      Parent = lcPedidosGroup_Root
      AlignHorz = ahClient
      CaptionOptions.Visible = False
      Control = lblMotivo
      ControlOptions.OriginalHeight = 19
      ControlOptions.OriginalWidth = 400
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object grpRodape: TdxLayoutGroup
      Parent = lcPedidosGroup_Root
      AlignHorz = ahClient
      CaptionOptions.Visible = False
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 3
    end
    object liAnterior: TdxLayoutItem
      Parent = grpRodape
      CaptionOptions.Visible = False
      Control = btnAnterior
      ControlOptions.OriginalHeight = 28
      ControlOptions.OriginalWidth = 90
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liPagina: TdxLayoutItem
      Parent = grpRodape
      AlignVert = avCenter
      CaptionOptions.Visible = False
      Control = lblPagina
      ControlOptions.OriginalHeight = 19
      ControlOptions.OriginalWidth = 170
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liProxima: TdxLayoutItem
      Parent = grpRodape
      CaptionOptions.Visible = False
      Control = btnProxima
      ControlOptions.OriginalHeight = 28
      ControlOptions.OriginalWidth = 90
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object liEscolher: TdxLayoutItem
      Parent = grpRodape
      AlignHorz = ahRight
      CaptionOptions.Visible = False
      Control = btnEscolher
      ControlOptions.OriginalHeight = 28
      ControlOptions.OriginalWidth = 100
      ControlOptions.ShowBorder = False
      Index = 3
    end
    object liCancelar: TdxLayoutItem
      Parent = grpRodape
      AlignHorz = ahRight
      CaptionOptions.Visible = False
      Control = btnCancelar
      ControlOptions.OriginalHeight = 28
      ControlOptions.OriginalWidth = 100
      ControlOptions.ShowBorder = False
      Index = 4
    end
  end
end
