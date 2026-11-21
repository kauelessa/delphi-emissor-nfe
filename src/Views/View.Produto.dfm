object frmProduto: TfrmProduto
  Left = 0
  Top = 0
  Caption = 'Produtos'
  ClientHeight = 560
  ClientWidth = 860
  Color = clBtnFace
  Constraints.MinHeight = 520
  Constraints.MinWidth = 760
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
  object pcProduto: TcxPageControl
    Left = 0
    Top = 0
    Width = 860
    Height = 560
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = tsLista
    Properties.CustomButtons.Buttons = <>
    Properties.HideTabs = True
    object tsLista: TcxTabSheet
      Caption = 'Lista'
      object lcLista: TdxLayoutControl
        Left = 0
        Top = 0
        Width = 860
        Height = 560
        Align = alClient
        TabOrder = 0
        object edtFiltro: TcxTextEdit
          Left = 12
          Top = 30
          Style.HotTrack = False
          TabOrder = 0
          TextHint = 'C'#243'digo, EAN ou descri'#231#227'o'
          OnKeyDown = edtFiltroKeyDown
          Width = 640
        end
        object btnPesquisar: TcxButton
          Left = 740
          Top = 28
          Width = 100
          Height = 26
          Caption = 'Pesquisar'
          TabOrder = 1
          OnClick = btnPesquisarClick
        end
        object grdProdutos: TcxGrid
          Left = 12
          Top = 64
          Width = 836
          Height = 440
          TabOrder = 2
          object tvProdutos: TcxGridTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnDblClick = tvProdutosDblClick
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
            object tvProdutosId: TcxGridColumn
              DataBinding.ValueType = 'Integer'
              Visible = False
            end
            object tvProdutosCodigo: TcxGridColumn
              Caption = 'C'#243'digo'
              Width = 80
            end
            object tvProdutosDescricao: TcxGridColumn
              Caption = 'Descri'#231#227'o'
              Width = 320
            end
            object tvProdutosNCM: TcxGridColumn
              Caption = 'NCM'
              Width = 80
            end
            object tvProdutosCst: TcxGridColumn
              Caption = 'CST/CSOSN'
              Width = 80
            end
            object tvProdutosUnidade: TcxGridColumn
              Caption = 'Un.'
              Width = 50
            end
            object tvProdutosPreco: TcxGridColumn
              Caption = 'Pre'#231'o'
              DataBinding.ValueType = 'Currency'
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;-,0.00'
              HeaderAlignmentHorz = taRightJustify
              Width = 90
            end
          end
          object lvProdutos: TcxGridLevel
            GridView = tvProdutos
          end
        end
        object btnNovo: TcxButton
          Left = 424
          Top = 520
          Width = 100
          Height = 28
          Caption = 'Novo'
          TabOrder = 3
          OnClick = btnNovoClick
        end
        object btnEditar: TcxButton
          Left = 530
          Top = 520
          Width = 100
          Height = 28
          Caption = 'Editar'
          TabOrder = 4
          OnClick = btnEditarClick
        end
        object btnInativar: TcxButton
          Left = 636
          Top = 520
          Width = 100
          Height = 28
          Caption = 'Inativar'
          TabOrder = 5
          OnClick = btnInativarClick
        end
        object btnFechar: TcxButton
          Left = 742
          Top = 520
          Width = 100
          Height = 28
          Cancel = True
          Caption = 'Fechar'
          ModalResult = 2
          TabOrder = 6
        end
        object lcListaGroup_Root: TdxLayoutGroup
          AlignHorz = ahClient
          AlignVert = avClient
          Hidden = True
          ShowBorder = False
          Index = -1
        end
        object grpFiltro: TdxLayoutGroup
          Parent = lcListaGroup_Root
          CaptionOptions.Visible = False
          LayoutDirection = ldHorizontal
          ShowBorder = False
          Index = 0
        end
        object liFiltro: TdxLayoutItem
          Parent = grpFiltro
          AlignHorz = ahClient
          CaptionOptions.Text = 'Pesquisar'
          Control = edtFiltro
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 640
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object liPesquisar: TdxLayoutItem
          Parent = grpFiltro
          CaptionOptions.Visible = False
          Control = btnPesquisar
          ControlOptions.OriginalHeight = 26
          ControlOptions.OriginalWidth = 100
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object liProdutos: TdxLayoutItem
          Parent = lcListaGroup_Root
          AlignHorz = ahClient
          AlignVert = avClient
          CaptionOptions.Visible = False
          Control = grdProdutos
          ControlOptions.OriginalHeight = 440
          ControlOptions.OriginalWidth = 836
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object grpBotoesLista: TdxLayoutGroup
          Parent = lcListaGroup_Root
          AlignHorz = ahRight
          CaptionOptions.Visible = False
          LayoutDirection = ldHorizontal
          ShowBorder = False
          Index = 2
        end
        object liNovo: TdxLayoutItem
          Parent = grpBotoesLista
          CaptionOptions.Visible = False
          Control = btnNovo
          ControlOptions.OriginalHeight = 28
          ControlOptions.OriginalWidth = 100
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object liEditar: TdxLayoutItem
          Parent = grpBotoesLista
          CaptionOptions.Visible = False
          Control = btnEditar
          ControlOptions.OriginalHeight = 28
          ControlOptions.OriginalWidth = 100
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object liInativar: TdxLayoutItem
          Parent = grpBotoesLista
          CaptionOptions.Visible = False
          Control = btnInativar
          ControlOptions.OriginalHeight = 28
          ControlOptions.OriginalWidth = 100
          ControlOptions.ShowBorder = False
          Index = 2
        end
        object liFechar: TdxLayoutItem
          Parent = grpBotoesLista
          CaptionOptions.Visible = False
          Control = btnFechar
          ControlOptions.OriginalHeight = 28
          ControlOptions.OriginalWidth = 100
          ControlOptions.ShowBorder = False
          Index = 3
        end
      end
    end
    object tsCadastro: TcxTabSheet
      Caption = 'Cadastro'
      object lcCadastro: TdxLayoutControl
        Left = 0
        Top = 0
        Width = 860
        Height = 560
        Align = alClient
        TabOrder = 0
        object edtCodigo: TcxTextEdit
          Left = 24
          Top = 50
          Properties.CharCase = ecUpperCase
          Properties.MaxLength = 60
          Style.HotTrack = False
          TabOrder = 0
          Width = 120
        end
        object edtDescricao: TcxTextEdit
          Left = 160
          Top = 50
          Properties.CharCase = ecUpperCase
          Properties.MaxLength = 120
          Style.HotTrack = False
          TabOrder = 1
          Width = 500
        end
        object edtEAN: TcxTextEdit
          Left = 24
          Top = 100
          Properties.CharCase = ecUpperCase
          Properties.MaxLength = 14
          Style.HotTrack = False
          TabOrder = 2
          Width = 150
        end
        object edtUnidade: TcxTextEdit
          Left = 190
          Top = 100
          Properties.CharCase = ecUpperCase
          Properties.MaxLength = 6
          Style.HotTrack = False
          TabOrder = 3
          Width = 70
        end
        object edtPreco: TcxCurrencyEdit
          Left = 276
          Top = 100
          Properties.DecimalPlaces = 4
          Properties.DisplayFormat = ',0.00##;-,0.00##'
          Style.HotTrack = False
          TabOrder = 4
          Width = 120
        end
        object edtNCM: TcxMaskEdit
          Left = 24
          Top = 180
          Properties.EditMask = '00000000;0;_'
          Style.HotTrack = False
          TabOrder = 5
          Width = 100
        end
        object edtCEST: TcxMaskEdit
          Left = 140
          Top = 180
          Properties.EditMask = '9999999;0;_'
          Style.HotTrack = False
          TabOrder = 6
          Width = 90
        end
        object edtCFOP: TcxMaskEdit
          Left = 246
          Top = 180
          Properties.EditMask = '0000;0;_'
          Style.HotTrack = False
          TabOrder = 7
          Width = 70
        end
        object cbOrigem: TcxComboBox
          Left = 332
          Top = 180
          Properties.DropDownListStyle = lsFixedList
          Properties.DropDownRows = 9
          Properties.DropDownWidth = 520
          Properties.Items.Strings = (
            '0 - Nacional'
            '1 - Estrangeira, importa'#231#227'o direta'
            '2 - Estrangeira, adquirida no mercado interno'
            '3 - Nacional, conte'#250'do de importa'#231#227'o superior a 40%'
            '4 - Nacional, produzida conforme processos produtivos b'#225'sicos'
            '5 - Nacional, conte'#250'do de importa'#231#227'o inferior ou igual a 40%'
            '6 - Estrangeira, importa'#231#227'o direta, sem similar nacional (CAMEX)'
            '7 - Estrangeira, mercado interno, sem similar nacional (CAMEX)'
            '8 - Nacional, conte'#250'do de importa'#231#227'o superior a 70%')
          Style.HotTrack = False
          TabOrder = 8
          Width = 300
        end
        object cbCstCsosn: TcxComboBox
          Left = 24
          Top = 230
          Properties.DropDownRows = 14
          Properties.DropDownWidth = 420
          Properties.Items.Strings = (
            '101 - Simples, com permiss'#227'o de cr'#233'dito'
            '102 - Simples, sem permiss'#227'o de cr'#233'dito'
            '103 - Simples, isen'#231#227'o por faixa de receita'
            '300 - Simples, imune'
            '400 - Simples, n'#227'o tributada'
            '500 - Simples, ICMS cobrado anteriormente por ST'
            '900 - Simples, outros'
            '00 - Tributada integralmente'
            '20 - Com redu'#231#227'o de base de c'#225'lculo'
            '40 - Isenta'
            '41 - N'#227'o tributada'
            '60 - ICMS cobrado anteriormente por ST')
          Style.HotTrack = False
          TabOrder = 9
          Width = 280
        end
        object edtAliquotaICMS: TcxCurrencyEdit
          Left = 320
          Top = 230
          Properties.DisplayFormat = ',0.00'
          Style.HotTrack = False
          TabOrder = 10
          Width = 90
        end
        object edtReducaoBC: TcxCurrencyEdit
          Left = 426
          Top = 230
          Properties.DisplayFormat = ',0.00'
          Style.HotTrack = False
          TabOrder = 11
          Width = 90
        end
        object cbCstPIS: TcxComboBox
          Left = 24
          Top = 280
          Properties.DropDownListStyle = lsFixedList
          Properties.DropDownWidth = 380
          Properties.Items.Strings = (
            '01 - Tribut'#225'vel, al'#237'quota b'#225'sica'
            '02 - Tribut'#225'vel, al'#237'quota diferenciada'
            '04 - Monof'#225'sica, revenda a al'#237'quota zero'
            '06 - Tribut'#225'vel a al'#237'quota zero'
            '07 - Isenta da contribui'#231#227'o'
            '08 - Sem incid'#234'ncia da contribui'#231#227'o'
            '09 - Com suspens'#227'o da contribui'#231#227'o'
            '49 - Outras opera'#231#245'es de sa'#237'da'
            '99 - Outras opera'#231#245'es')
          Style.HotTrack = False
          TabOrder = 12
          Width = 200
        end
        object edtAliquotaPIS: TcxCurrencyEdit
          Left = 240
          Top = 280
          Properties.DisplayFormat = ',0.00##'
          Properties.DecimalPlaces = 4
          Style.HotTrack = False
          TabOrder = 13
          Width = 80
        end
        object cbCstCOFINS: TcxComboBox
          Left = 336
          Top = 280
          Properties.DropDownListStyle = lsFixedList
          Properties.DropDownWidth = 380
          Properties.Items.Strings = (
            '01 - Tribut'#225'vel, al'#237'quota b'#225'sica'
            '02 - Tribut'#225'vel, al'#237'quota diferenciada'
            '04 - Monof'#225'sica, revenda a al'#237'quota zero'
            '06 - Tribut'#225'vel a al'#237'quota zero'
            '07 - Isenta da contribui'#231#227'o'
            '08 - Sem incid'#234'ncia da contribui'#231#227'o'
            '09 - Com suspens'#227'o da contribui'#231#227'o'
            '49 - Outras opera'#231#245'es de sa'#237'da'
            '99 - Outras opera'#231#245'es')
          Style.HotTrack = False
          TabOrder = 14
          Width = 200
        end
        object edtAliquotaCOFINS: TcxCurrencyEdit
          Left = 552
          Top = 280
          Properties.DisplayFormat = ',0.00##'
          Properties.DecimalPlaces = 4
          Style.HotTrack = False
          TabOrder = 15
          Width = 80
        end
        object btnSalvar: TcxButton
          Left = 636
          Top = 520
          Width = 100
          Height = 28
          Caption = 'Salvar'
          TabOrder = 16
          OnClick = btnSalvarClick
        end
        object btnCancelar: TcxButton
          Left = 742
          Top = 520
          Width = 100
          Height = 28
          Caption = 'Cancelar'
          TabOrder = 17
          OnClick = btnCancelarClick
        end
        object lcCadastroGroup_Root: TdxLayoutGroup
          AlignHorz = ahClient
          AlignVert = avClient
          Hidden = True
          ShowBorder = False
          Index = -1
        end
        object grpDados: TdxLayoutGroup
          Parent = lcCadastroGroup_Root
          CaptionOptions.Text = 'Produto'
          Index = 0
        end
        object grpDados1: TdxLayoutGroup
          Parent = grpDados
          CaptionOptions.Visible = False
          LayoutDirection = ldHorizontal
          ShowBorder = False
          Index = 0
        end
        object liCodigo: TdxLayoutItem
          Parent = grpDados1
          CaptionOptions.Text = 'C'#243'digo'
          CaptionOptions.Layout = clTop
          Control = edtCodigo
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 120
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object liDescricao: TdxLayoutItem
          Parent = grpDados1
          AlignHorz = ahClient
          CaptionOptions.Text = 'Descri'#231#227'o'
          CaptionOptions.Layout = clTop
          Control = edtDescricao
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 500
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object grpDados2: TdxLayoutGroup
          Parent = grpDados
          CaptionOptions.Visible = False
          LayoutDirection = ldHorizontal
          ShowBorder = False
          Index = 1
        end
        object liEAN: TdxLayoutItem
          Parent = grpDados2
          CaptionOptions.Text = 'GTIN/EAN'
          CaptionOptions.Layout = clTop
          Control = edtEAN
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 150
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object liUnidade: TdxLayoutItem
          Parent = grpDados2
          CaptionOptions.Text = 'Unidade'
          CaptionOptions.Layout = clTop
          Control = edtUnidade
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 70
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object liPreco: TdxLayoutItem
          Parent = grpDados2
          CaptionOptions.Text = 'Pre'#231'o de venda'
          CaptionOptions.Layout = clTop
          Control = edtPreco
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 120
          ControlOptions.ShowBorder = False
          Index = 2
        end
        object grpFiscal: TdxLayoutGroup
          Parent = lcCadastroGroup_Root
          CaptionOptions.Text = 'Tributa'#231#227'o'
          Index = 1
        end
        object grpFiscal1: TdxLayoutGroup
          Parent = grpFiscal
          CaptionOptions.Visible = False
          LayoutDirection = ldHorizontal
          ShowBorder = False
          Index = 0
        end
        object liNCM: TdxLayoutItem
          Parent = grpFiscal1
          CaptionOptions.Text = 'NCM'
          CaptionOptions.Layout = clTop
          Control = edtNCM
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 100
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object liCEST: TdxLayoutItem
          Parent = grpFiscal1
          CaptionOptions.Text = 'CEST'
          CaptionOptions.Layout = clTop
          Control = edtCEST
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 90
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object liCFOP: TdxLayoutItem
          Parent = grpFiscal1
          CaptionOptions.Text = 'CFOP'
          CaptionOptions.Layout = clTop
          Control = edtCFOP
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 70
          ControlOptions.ShowBorder = False
          Index = 2
        end
        object liOrigem: TdxLayoutItem
          Parent = grpFiscal1
          AlignHorz = ahClient
          CaptionOptions.Text = 'Origem da mercadoria'
          CaptionOptions.Layout = clTop
          Control = cbOrigem
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 300
          ControlOptions.ShowBorder = False
          Index = 3
        end
        object grpFiscal2: TdxLayoutGroup
          Parent = grpFiscal
          CaptionOptions.Visible = False
          LayoutDirection = ldHorizontal
          ShowBorder = False
          Index = 1
        end
        object liCstCsosn: TdxLayoutItem
          Parent = grpFiscal2
          CaptionOptions.Text = 'CST / CSOSN do ICMS'
          CaptionOptions.Layout = clTop
          Control = cbCstCsosn
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 280
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object liAliquotaICMS: TdxLayoutItem
          Parent = grpFiscal2
          CaptionOptions.Text = 'Al'#237'quota ICMS %'
          CaptionOptions.Layout = clTop
          Control = edtAliquotaICMS
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 90
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object liReducaoBC: TdxLayoutItem
          Parent = grpFiscal2
          CaptionOptions.Text = 'Redu'#231#227'o BC %'
          CaptionOptions.Layout = clTop
          Control = edtReducaoBC
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 90
          ControlOptions.ShowBorder = False
          Index = 2
        end
        object grpFiscal3: TdxLayoutGroup
          Parent = grpFiscal
          CaptionOptions.Visible = False
          LayoutDirection = ldHorizontal
          ShowBorder = False
          Index = 2
        end
        object liCstPIS: TdxLayoutItem
          Parent = grpFiscal3
          CaptionOptions.Text = 'CST PIS'
          CaptionOptions.Layout = clTop
          Control = cbCstPIS
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 200
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object liAliquotaPIS: TdxLayoutItem
          Parent = grpFiscal3
          CaptionOptions.Text = 'Al'#237'quota PIS %'
          CaptionOptions.Layout = clTop
          Control = edtAliquotaPIS
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 80
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object liCstCOFINS: TdxLayoutItem
          Parent = grpFiscal3
          CaptionOptions.Text = 'CST COFINS'
          CaptionOptions.Layout = clTop
          Control = cbCstCOFINS
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 200
          ControlOptions.ShowBorder = False
          Index = 2
        end
        object liAliquotaCOFINS: TdxLayoutItem
          Parent = grpFiscal3
          CaptionOptions.Text = 'Al'#237'quota COFINS %'
          CaptionOptions.Layout = clTop
          Control = edtAliquotaCOFINS
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 80
          ControlOptions.ShowBorder = False
          Index = 3
        end
        object grpBotoesCadastro: TdxLayoutGroup
          Parent = lcCadastroGroup_Root
          AlignHorz = ahRight
          AlignVert = avBottom
          CaptionOptions.Visible = False
          LayoutDirection = ldHorizontal
          ShowBorder = False
          Index = 2
        end
        object liSalvar: TdxLayoutItem
          Parent = grpBotoesCadastro
          CaptionOptions.Visible = False
          Control = btnSalvar
          ControlOptions.OriginalHeight = 28
          ControlOptions.OriginalWidth = 100
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object liCancelar: TdxLayoutItem
          Parent = grpBotoesCadastro
          CaptionOptions.Visible = False
          Control = btnCancelar
          ControlOptions.OriginalHeight = 28
          ControlOptions.OriginalWidth = 100
          ControlOptions.ShowBorder = False
          Index = 1
        end
      end
    end
  end
end
