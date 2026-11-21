object frmCliente: TfrmCliente
  Left = 0
  Top = 0
  Caption = 'Clientes'
  ClientHeight = 540
  ClientWidth = 820
  Color = clBtnFace
  Constraints.MinHeight = 500
  Constraints.MinWidth = 720
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
  object pcCliente: TcxPageControl
    Left = 0
    Top = 0
    Width = 820
    Height = 540
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
        Width = 820
        Height = 540
        Align = alClient
        TabOrder = 0
        object edtFiltro: TcxTextEdit
          Left = 12
          Top = 30
          Style.HotTrack = False
          TabOrder = 0
          TextHint = 'Nome ou CPF/CNPJ'
          OnKeyDown = edtFiltroKeyDown
          Width = 600
        end
        object btnPesquisar: TcxButton
          Left = 700
          Top = 28
          Width = 100
          Height = 26
          Caption = 'Pesquisar'
          TabOrder = 1
          OnClick = btnPesquisarClick
        end
        object grdClientes: TcxGrid
          Left = 12
          Top = 64
          Width = 796
          Height = 420
          TabOrder = 2
          object tvClientes: TcxGridTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnDblClick = tvClientesDblClick
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
            object tvClientesId: TcxGridColumn
              DataBinding.ValueType = 'Integer'
              Visible = False
            end
            object tvClientesNome: TcxGridColumn
              Caption = 'Nome'
              Width = 280
            end
            object tvClientesDocumento: TcxGridColumn
              Caption = 'CPF/CNPJ'
              Width = 140
            end
            object tvClientesCidade: TcxGridColumn
              Caption = 'Munic'#237'pio/UF'
              Width = 160
            end
            object tvClientesEmail: TcxGridColumn
              Caption = 'E-mail'
              Width = 200
            end
          end
          object lvClientes: TcxGridLevel
            GridView = tvClientes
          end
        end
        object btnNovo: TcxButton
          Left = 384
          Top = 500
          Width = 100
          Height = 28
          Caption = 'Novo'
          TabOrder = 3
          OnClick = btnNovoClick
        end
        object btnEditar: TcxButton
          Left = 490
          Top = 500
          Width = 100
          Height = 28
          Caption = 'Editar'
          TabOrder = 4
          OnClick = btnEditarClick
        end
        object btnInativar: TcxButton
          Left = 596
          Top = 500
          Width = 100
          Height = 28
          Caption = 'Inativar'
          TabOrder = 5
          OnClick = btnInativarClick
        end
        object btnFechar: TcxButton
          Left = 702
          Top = 500
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
          ControlOptions.OriginalWidth = 600
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
        object liClientes: TdxLayoutItem
          Parent = lcListaGroup_Root
          AlignHorz = ahClient
          AlignVert = avClient
          CaptionOptions.Visible = False
          Control = grdClientes
          ControlOptions.OriginalHeight = 420
          ControlOptions.OriginalWidth = 796
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
        Width = 820
        Height = 540
        Align = alClient
        TabOrder = 0
        object edtNome: TcxTextEdit
          Left = 24
          Top = 50
          Properties.CharCase = ecUpperCase
          Properties.MaxLength = 60
          Style.HotTrack = False
          TabOrder = 0
          Width = 500
        end
        object edtCpfCnpj: TcxTextEdit
          Left = 540
          Top = 50
          Properties.MaxLength = 18
          Style.HotTrack = False
          TabOrder = 1
          Width = 160
        end
        object cbIndicadorIE: TcxComboBox
          Left = 24
          Top = 100
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            '1 - Contribuinte ICMS'
            '2 - Contribuinte isento'
            '9 - N'#227'o contribuinte')
          Style.HotTrack = False
          TabOrder = 2
          Width = 200
        end
        object edtIE: TcxTextEdit
          Left = 240
          Top = 100
          Properties.MaxLength = 14
          Style.HotTrack = False
          TabOrder = 3
          Width = 160
        end
        object edtEmail: TcxTextEdit
          Left = 24
          Top = 150
          Properties.CharCase = ecLowerCase
          Properties.MaxLength = 100
          Style.HotTrack = False
          TabOrder = 4
          Width = 400
        end
        object edtTelefone: TcxTextEdit
          Left = 440
          Top = 150
          Properties.MaxLength = 15
          Style.HotTrack = False
          TabOrder = 5
          Width = 140
        end
        object edtLogradouro: TcxTextEdit
          Left = 24
          Top = 230
          Properties.CharCase = ecUpperCase
          Properties.MaxLength = 60
          Style.HotTrack = False
          TabOrder = 6
          Width = 500
        end
        object edtNumero: TcxTextEdit
          Left = 540
          Top = 230
          Properties.MaxLength = 60
          Style.HotTrack = False
          TabOrder = 7
          Width = 90
        end
        object edtComplemento: TcxTextEdit
          Left = 24
          Top = 280
          Properties.CharCase = ecUpperCase
          Properties.MaxLength = 60
          Style.HotTrack = False
          TabOrder = 8
          Width = 300
        end
        object edtBairro: TcxTextEdit
          Left = 340
          Top = 280
          Properties.CharCase = ecUpperCase
          Properties.MaxLength = 60
          Style.HotTrack = False
          TabOrder = 9
          Width = 300
        end
        object edtCodigoMunicipio: TcxMaskEdit
          Left = 24
          Top = 330
          Properties.EditMask = '0000000;0;_'
          Style.HotTrack = False
          TabOrder = 10
          Width = 110
        end
        object edtMunicipio: TcxTextEdit
          Left = 150
          Top = 330
          Properties.CharCase = ecUpperCase
          Properties.MaxLength = 60
          Style.HotTrack = False
          TabOrder = 11
          Width = 300
        end
        object cbUF: TcxComboBox
          Left = 466
          Top = 330
          Properties.DropDownListStyle = lsFixedList
          Properties.DropDownRows = 14
          Properties.Items.Strings = (
            'AC'
            'AL'
            'AM'
            'AP'
            'BA'
            'CE'
            'DF'
            'ES'
            'GO'
            'MA'
            'MG'
            'MS'
            'MT'
            'PA'
            'PB'
            'PE'
            'PI'
            'PR'
            'RJ'
            'RN'
            'RO'
            'RR'
            'RS'
            'SC'
            'SE'
            'SP'
            'TO')
          Style.HotTrack = False
          TabOrder = 12
          Width = 70
        end
        object edtCEP: TcxMaskEdit
          Left = 552
          Top = 330
          Properties.EditMask = '00000-000;0;_'
          Style.HotTrack = False
          TabOrder = 13
          Width = 100
        end
        object btnSalvar: TcxButton
          Left = 596
          Top = 500
          Width = 100
          Height = 28
          Caption = 'Salvar'
          TabOrder = 14
          OnClick = btnSalvarClick
        end
        object btnCancelar: TcxButton
          Left = 702
          Top = 500
          Width = 100
          Height = 28
          Caption = 'Cancelar'
          TabOrder = 15
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
          CaptionOptions.Text = 'Dados do cliente'
          Index = 0
        end
        object grpLinha1: TdxLayoutGroup
          Parent = grpDados
          CaptionOptions.Visible = False
          LayoutDirection = ldHorizontal
          ShowBorder = False
          Index = 0
        end
        object liNome: TdxLayoutItem
          Parent = grpLinha1
          AlignHorz = ahClient
          CaptionOptions.Text = 'Nome / raz'#227'o social'
          CaptionOptions.Layout = clTop
          Control = edtNome
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 500
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object liCpfCnpj: TdxLayoutItem
          Parent = grpLinha1
          CaptionOptions.Text = 'CPF/CNPJ'
          CaptionOptions.Layout = clTop
          Control = edtCpfCnpj
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 160
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object grpLinha2: TdxLayoutGroup
          Parent = grpDados
          CaptionOptions.Visible = False
          LayoutDirection = ldHorizontal
          ShowBorder = False
          Index = 1
        end
        object liIndicadorIE: TdxLayoutItem
          Parent = grpLinha2
          CaptionOptions.Text = 'Indicador da IE'
          CaptionOptions.Layout = clTop
          Control = cbIndicadorIE
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 200
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object liIE: TdxLayoutItem
          Parent = grpLinha2
          CaptionOptions.Text = 'Inscri'#231#227'o estadual'
          CaptionOptions.Layout = clTop
          Control = edtIE
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 160
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object grpLinha3: TdxLayoutGroup
          Parent = grpDados
          CaptionOptions.Visible = False
          LayoutDirection = ldHorizontal
          ShowBorder = False
          Index = 2
        end
        object liEmail: TdxLayoutItem
          Parent = grpLinha3
          AlignHorz = ahClient
          CaptionOptions.Text = 'E-mail'
          CaptionOptions.Layout = clTop
          Control = edtEmail
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 400
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object liTelefone: TdxLayoutItem
          Parent = grpLinha3
          CaptionOptions.Text = 'Telefone'
          CaptionOptions.Layout = clTop
          Control = edtTelefone
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 140
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object grpEndereco: TdxLayoutGroup
          Parent = lcCadastroGroup_Root
          CaptionOptions.Text = 'Endere'#231'o (obrigat'#243'rio para NF-e)'
          Index = 1
        end
        object grpEndereco1: TdxLayoutGroup
          Parent = grpEndereco
          CaptionOptions.Visible = False
          LayoutDirection = ldHorizontal
          ShowBorder = False
          Index = 0
        end
        object liLogradouro: TdxLayoutItem
          Parent = grpEndereco1
          AlignHorz = ahClient
          CaptionOptions.Text = 'Logradouro'
          CaptionOptions.Layout = clTop
          Control = edtLogradouro
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 500
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object liNumero: TdxLayoutItem
          Parent = grpEndereco1
          CaptionOptions.Text = 'N'#250'mero'
          CaptionOptions.Layout = clTop
          Control = edtNumero
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 90
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object grpEndereco2: TdxLayoutGroup
          Parent = grpEndereco
          CaptionOptions.Visible = False
          LayoutDirection = ldHorizontal
          ShowBorder = False
          Index = 1
        end
        object liComplemento: TdxLayoutItem
          Parent = grpEndereco2
          AlignHorz = ahClient
          CaptionOptions.Text = 'Complemento'
          CaptionOptions.Layout = clTop
          Control = edtComplemento
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 300
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object liBairro: TdxLayoutItem
          Parent = grpEndereco2
          AlignHorz = ahClient
          CaptionOptions.Text = 'Bairro'
          CaptionOptions.Layout = clTop
          Control = edtBairro
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 300
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object grpEndereco3: TdxLayoutGroup
          Parent = grpEndereco
          CaptionOptions.Visible = False
          LayoutDirection = ldHorizontal
          ShowBorder = False
          Index = 2
        end
        object liCodigoMunicipio: TdxLayoutItem
          Parent = grpEndereco3
          CaptionOptions.Text = 'C'#243'd. munic'#237'pio (IBGE)'
          CaptionOptions.Layout = clTop
          Control = edtCodigoMunicipio
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 110
          ControlOptions.ShowBorder = False
          Index = 0
        end
        object liMunicipio: TdxLayoutItem
          Parent = grpEndereco3
          AlignHorz = ahClient
          CaptionOptions.Text = 'Munic'#237'pio'
          CaptionOptions.Layout = clTop
          Control = edtMunicipio
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 300
          ControlOptions.ShowBorder = False
          Index = 1
        end
        object liUF: TdxLayoutItem
          Parent = grpEndereco3
          CaptionOptions.Text = 'UF'
          CaptionOptions.Layout = clTop
          Control = cbUF
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 70
          ControlOptions.ShowBorder = False
          Index = 2
        end
        object liCEP: TdxLayoutItem
          Parent = grpEndereco3
          CaptionOptions.Text = 'CEP'
          CaptionOptions.Layout = clTop
          Control = edtCEP
          ControlOptions.OriginalHeight = 23
          ControlOptions.OriginalWidth = 100
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
