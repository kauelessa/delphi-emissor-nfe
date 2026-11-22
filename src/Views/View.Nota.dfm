object frmNota: TfrmNota
  Left = 0
  Top = 0
  Caption = 'Emiss'#227'o'
  ClientHeight = 680
  ClientWidth = 1000
  Color = clBtnFace
  Constraints.MinHeight = 640
  Constraints.MinWidth = 900
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poOwnerFormCenter
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 15
  object lcNota: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 1000
    Height = 680
    Align = alClient
    TabOrder = 0
    object cbCliente: TcxComboBox
      Left = 24
      Top = 50
      Properties.DropDownListStyle = lsFixedList
      Properties.DropDownRows = 15
      Properties.OnChange = cbClientePropertiesChange
      Style.HotTrack = False
      TabOrder = 0
      Width = 600
    end
    object edtCpfConsumidor: TcxTextEdit
      Left = 640
      Top = 50
      Properties.MaxLength = 18
      Style.HotTrack = False
      TabOrder = 1
      Width = 160
    end
    object edtObservacao: TcxTextEdit
      Left = 24
      Top = 100
      Properties.MaxLength = 2000
      Style.HotTrack = False
      TabOrder = 2
      Width = 900
    end
    object cbProduto: TcxComboBox
      Left = 24
      Top = 170
      Properties.DropDownListStyle = lsFixedList
      Properties.DropDownRows = 15
      Style.HotTrack = False
      TabOrder = 3
      Width = 560
    end
    object edtQuantidade: TcxCurrencyEdit
      Left = 600
      Top = 170
      EditValue = 1.000000000000000000
      Properties.DecimalPlaces = 4
      Properties.DisplayFormat = ',0.####'
      Style.HotTrack = False
      TabOrder = 4
      OnKeyDown = edtQuantidadeKeyDown
      Width = 90
    end
    object btnAdicionarItem: TcxButton
      Left = 700
      Top = 168
      Width = 110
      Height = 26
      Caption = 'Adicionar'
      TabOrder = 5
      OnClick = btnAdicionarItemClick
    end
    object btnRemoverItem: TcxButton
      Left = 816
      Top = 168
      Width = 110
      Height = 26
      Caption = 'Remover item'
      TabOrder = 6
      OnClick = btnRemoverItemClick
    end
    object btnImportarPedido: TcxButton
      Left = 816
      Top = 168
      Width = 130
      Height = 26
      Hint = 'Preenche a nota com um pedido da delphi-horse-api'
      Caption = 'Importar pedido...'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 7
      OnClick = btnImportarPedidoClick
    end
    object grdItens: TcxGrid
      Left = 24
      Top = 204
      Width = 952
      Height = 230
      TabOrder = 7
      object tvItens: TcxGridTableView
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
        object tvItensNumero: TcxGridColumn
          Caption = 'Item'
          DataBinding.ValueType = 'Integer'
          Width = 45
        end
        object tvItensCodigo: TcxGridColumn
          Caption = 'C'#243'digo'
          Width = 80
        end
        object tvItensDescricao: TcxGridColumn
          Caption = 'Descri'#231#227'o'
          Width = 340
        end
        object tvItensQuantidade: TcxGridColumn
          Caption = 'Qtd.'
          DataBinding.ValueType = 'Currency'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.####'
          HeaderAlignmentHorz = taRightJustify
          Width = 70
        end
        object tvItensUnitario: TcxGridColumn
          Caption = 'Unit'#225'rio'
          DataBinding.ValueType = 'Currency'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00##'
          HeaderAlignmentHorz = taRightJustify
          Width = 90
        end
        object tvItensDesconto: TcxGridColumn
          Caption = 'Desconto'
          DataBinding.ValueType = 'Currency'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00'
          HeaderAlignmentHorz = taRightJustify
          Width = 80
        end
        object tvItensTotal: TcxGridColumn
          Caption = 'Total'
          DataBinding.ValueType = 'Currency'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00'
          HeaderAlignmentHorz = taRightJustify
          Width = 90
        end
      end
      object lvItens: TcxGridLevel
        GridView = tvItens
      end
    end
    object cbFormaPagamento: TcxComboBox
      Left = 36
      Top = 480
      Properties.DropDownListStyle = lsFixedList
      Style.HotTrack = False
      TabOrder = 8
      Width = 200
    end
    object edtValorPagamento: TcxCurrencyEdit
      Left = 246
      Top = 480
      Properties.DisplayFormat = ',0.00'
      Style.HotTrack = False
      TabOrder = 9
      Width = 100
    end
    object btnAdicionarPagamento: TcxButton
      Left = 356
      Top = 478
      Width = 90
      Height = 26
      Caption = 'Incluir'
      TabOrder = 10
      OnClick = btnAdicionarPagamentoClick
    end
    object btnRemoverPagamento: TcxButton
      Left = 452
      Top = 478
      Width = 90
      Height = 26
      Caption = 'Remover'
      TabOrder = 11
      OnClick = btnRemoverPagamentoClick
    end
    object grdPagamentos: TcxGrid
      Left = 36
      Top = 512
      Width = 560
      Height = 100
      TabOrder = 12
      object tvPagamentos: TcxGridTableView
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
        object tvPagamentosForma: TcxGridColumn
          Caption = 'Forma de pagamento'
          Width = 300
        end
        object tvPagamentosValor: TcxGridColumn
          Caption = 'Valor'
          DataBinding.ValueType = 'Currency'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00'
          HeaderAlignmentHorz = taRightJustify
          Width = 100
        end
      end
      object lvPagamentos: TcxGridLevel
        GridView = tvPagamentos
      end
    end
    object edtDesconto: TcxCurrencyEdit
      Left = 640
      Top = 480
      Properties.DisplayFormat = ',0.00'
      Style.HotTrack = False
      TabOrder = 13
      Width = 100
    end
    object btnAplicarDesconto: TcxButton
      Left = 750
      Top = 478
      Width = 110
      Height = 26
      Caption = 'Aplicar desconto'
      TabOrder = 14
      OnClick = btnAplicarDescontoClick
    end
    object lblProdutos: TcxLabel
      Left = 640
      Top = 512
      Caption = 'Produtos: R$ 0,00'
      Transparent = True
    end
    object lblDesconto: TcxLabel
      Left = 640
      Top = 532
      Caption = 'Desconto: R$ 0,00'
      Transparent = True
    end
    object lblTotal: TcxLabel
      Left = 640
      Top = 552
      Caption = 'TOTAL: R$ 0,00'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clNavy
      Style.Font.Height = -21
      Style.Font.Name = 'Segoe UI'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object lblPago: TcxLabel
      Left = 640
      Top = 584
      Caption = 'Pago: R$ 0,00'
      Transparent = True
    end
    object lblTroco: TcxLabel
      Left = 640
      Top = 604
      Caption = 'Troco: R$ 0,00'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -13
      Style.Font.Name = 'Segoe UI'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object btnNovaNota: TcxButton
      Left = 640
      Top = 640
      Width = 110
      Height = 30
      Caption = 'Nova nota'
      TabOrder = 15
      OnClick = btnNovaNotaClick
    end
    object btnEmitir: TcxButton
      Left = 756
      Top = 640
      Width = 120
      Height = 30
      Caption = 'Emitir (F5)'
      TabOrder = 16
      OnClick = btnEmitirClick
    end
    object btnFechar: TcxButton
      Left = 882
      Top = 640
      Width = 100
      Height = 30
      Cancel = True
      Caption = 'Fechar'
      ModalResult = 2
      TabOrder = 17
    end
    object lcNotaGroup_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      Hidden = True
      ShowBorder = False
      Index = -1
    end
    object grpCabecalho: TdxLayoutGroup
      Parent = lcNotaGroup_Root
      CaptionOptions.Text = 'Destinat'#225'rio'
      Index = 0
    end
    object grpCabecalho1: TdxLayoutGroup
      Parent = grpCabecalho
      CaptionOptions.Visible = False
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 0
    end
    object liCliente: TdxLayoutItem
      Parent = grpCabecalho1
      AlignHorz = ahClient
      CaptionOptions.Text = 'Cliente'
      CaptionOptions.Layout = clTop
      Control = cbCliente
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 600
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liCpfConsumidor: TdxLayoutItem
      Parent = grpCabecalho1
      CaptionOptions.Text = 'CPF/CNPJ na nota'
      CaptionOptions.Layout = clTop
      Control = edtCpfConsumidor
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 160
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liObservacao: TdxLayoutItem
      Parent = grpCabecalho
      AlignHorz = ahClient
      CaptionOptions.Text = 'Informa'#231#245'es complementares'
      CaptionOptions.Layout = clTop
      Control = edtObservacao
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 900
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object grpItens: TdxLayoutGroup
      Parent = lcNotaGroup_Root
      AlignVert = avClient
      CaptionOptions.Text = 'Itens'
      Index = 1
    end
    object grpItens1: TdxLayoutGroup
      Parent = grpItens
      CaptionOptions.Visible = False
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 0
    end
    object liProduto: TdxLayoutItem
      Parent = grpItens1
      AlignHorz = ahClient
      CaptionOptions.Text = 'Produto (F2)'
      CaptionOptions.Layout = clTop
      Control = cbProduto
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 560
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liQuantidade: TdxLayoutItem
      Parent = grpItens1
      CaptionOptions.Text = 'Quantidade'
      CaptionOptions.Layout = clTop
      Control = edtQuantidade
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 90
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liAdicionarItem: TdxLayoutItem
      Parent = grpItens1
      AlignVert = avBottom
      CaptionOptions.Visible = False
      Control = btnAdicionarItem
      ControlOptions.OriginalHeight = 26
      ControlOptions.OriginalWidth = 110
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object liRemoverItem: TdxLayoutItem
      Parent = grpItens1
      AlignVert = avBottom
      CaptionOptions.Visible = False
      Control = btnRemoverItem
      ControlOptions.OriginalHeight = 26
      ControlOptions.OriginalWidth = 110
      ControlOptions.ShowBorder = False
      Index = 3
    end
    object liImportarPedido: TdxLayoutItem
      Parent = grpItens1
      AlignHorz = ahRight
      AlignVert = avBottom
      CaptionOptions.Visible = False
      Control = btnImportarPedido
      ControlOptions.OriginalHeight = 26
      ControlOptions.OriginalWidth = 130
      ControlOptions.ShowBorder = False
      Index = 4
    end
    object liItens: TdxLayoutItem
      Parent = grpItens
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Visible = False
      Control = grdItens
      ControlOptions.OriginalHeight = 230
      ControlOptions.OriginalWidth = 952
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object grpRodape: TdxLayoutGroup
      Parent = lcNotaGroup_Root
      CaptionOptions.Visible = False
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 2
    end
    object grpPagamento: TdxLayoutGroup
      Parent = grpRodape
      AlignHorz = ahClient
      CaptionOptions.Text = 'Pagamento (F6)'
      Index = 0
    end
    object grpPagamento1: TdxLayoutGroup
      Parent = grpPagamento
      CaptionOptions.Visible = False
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 0
    end
    object liFormaPagamento: TdxLayoutItem
      Parent = grpPagamento1
      AlignHorz = ahClient
      CaptionOptions.Text = 'Forma'
      CaptionOptions.Layout = clTop
      Control = cbFormaPagamento
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 200
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liValorPagamento: TdxLayoutItem
      Parent = grpPagamento1
      CaptionOptions.Text = 'Valor'
      CaptionOptions.Layout = clTop
      Control = edtValorPagamento
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 100
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liAdicionarPagamento: TdxLayoutItem
      Parent = grpPagamento1
      AlignVert = avBottom
      CaptionOptions.Visible = False
      Control = btnAdicionarPagamento
      ControlOptions.OriginalHeight = 26
      ControlOptions.OriginalWidth = 90
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object liRemoverPagamento: TdxLayoutItem
      Parent = grpPagamento1
      AlignVert = avBottom
      CaptionOptions.Visible = False
      Control = btnRemoverPagamento
      ControlOptions.OriginalHeight = 26
      ControlOptions.OriginalWidth = 90
      ControlOptions.ShowBorder = False
      Index = 3
    end
    object liPagamentos: TdxLayoutItem
      Parent = grpPagamento
      AlignHorz = ahClient
      CaptionOptions.Visible = False
      Control = grdPagamentos
      ControlOptions.OriginalHeight = 100
      ControlOptions.OriginalWidth = 560
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object grpTotais: TdxLayoutGroup
      Parent = grpRodape
      CaptionOptions.Text = 'Totais'
      Index = 1
    end
    object grpDesconto: TdxLayoutGroup
      Parent = grpTotais
      CaptionOptions.Visible = False
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 0
    end
    object liDesconto: TdxLayoutItem
      Parent = grpDesconto
      CaptionOptions.Text = 'Desconto na nota'
      CaptionOptions.Layout = clTop
      Control = edtDesconto
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 100
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liAplicarDesconto: TdxLayoutItem
      Parent = grpDesconto
      AlignVert = avBottom
      CaptionOptions.Visible = False
      Control = btnAplicarDesconto
      ControlOptions.OriginalHeight = 26
      ControlOptions.OriginalWidth = 110
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liProdutos: TdxLayoutItem
      Parent = grpTotais
      CaptionOptions.Visible = False
      Control = lblProdutos
      ControlOptions.OriginalHeight = 19
      ControlOptions.OriginalWidth = 220
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liDescontoTotal: TdxLayoutItem
      Parent = grpTotais
      CaptionOptions.Visible = False
      Control = lblDesconto
      ControlOptions.OriginalHeight = 19
      ControlOptions.OriginalWidth = 220
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object liTotal: TdxLayoutItem
      Parent = grpTotais
      CaptionOptions.Visible = False
      Control = lblTotal
      ControlOptions.OriginalHeight = 30
      ControlOptions.OriginalWidth = 260
      ControlOptions.ShowBorder = False
      Index = 3
    end
    object liPago: TdxLayoutItem
      Parent = grpTotais
      CaptionOptions.Visible = False
      Control = lblPago
      ControlOptions.OriginalHeight = 19
      ControlOptions.OriginalWidth = 220
      ControlOptions.ShowBorder = False
      Index = 4
    end
    object liTroco: TdxLayoutItem
      Parent = grpTotais
      CaptionOptions.Visible = False
      Control = lblTroco
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 220
      ControlOptions.ShowBorder = False
      Index = 5
    end
    object grpAcoes: TdxLayoutGroup
      Parent = lcNotaGroup_Root
      AlignHorz = ahRight
      CaptionOptions.Visible = False
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 3
    end
    object liNovaNota: TdxLayoutItem
      Parent = grpAcoes
      CaptionOptions.Visible = False
      Control = btnNovaNota
      ControlOptions.OriginalHeight = 30
      ControlOptions.OriginalWidth = 110
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liEmitir: TdxLayoutItem
      Parent = grpAcoes
      CaptionOptions.Visible = False
      Control = btnEmitir
      ControlOptions.OriginalHeight = 30
      ControlOptions.OriginalWidth = 120
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liFechar: TdxLayoutItem
      Parent = grpAcoes
      CaptionOptions.Visible = False
      Control = btnFechar
      ControlOptions.OriginalHeight = 30
      ControlOptions.OriginalWidth = 100
      ControlOptions.ShowBorder = False
      Index = 2
    end
  end
end
