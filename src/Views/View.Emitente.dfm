object frmEmitente: TfrmEmitente
  Left = 0
  Top = 0
  Caption = 'Emitente'
  ClientHeight = 600
  ClientWidth = 800
  Color = clBtnFace
  Constraints.MinHeight = 600
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
  object lcEmitente: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 800
    Height = 600
    Align = alClient
    TabOrder = 0
    object edtRazaoSocial: TcxTextEdit
      Left = 24
      Top = 50
      Properties.CharCase = ecUpperCase
      Properties.MaxLength = 60
      Style.HotTrack = False
      TabOrder = 0
      Width = 400
    end
    object edtNomeFantasia: TcxTextEdit
      Left = 440
      Top = 50
      Properties.CharCase = ecUpperCase
      Properties.MaxLength = 60
      Style.HotTrack = False
      TabOrder = 1
      Width = 300
    end
    object edtCNPJ: TcxMaskEdit
      Left = 24
      Top = 100
      Properties.EditMask = '00.000.000/0000-00;0;_'
      Style.HotTrack = False
      TabOrder = 2
      Width = 140
    end
    object edtIE: TcxTextEdit
      Left = 180
      Top = 100
      Properties.CharCase = ecUpperCase
      Properties.MaxLength = 14
      Style.HotTrack = False
      TabOrder = 3
      Width = 140
    end
    object cbCRT: TcxComboBox
      Left = 336
      Top = 100
      Properties.DropDownListStyle = lsFixedList
      Properties.Items.Strings = (
        '1 - Simples Nacional'
        '2 - Simples Nacional (excesso de sublimite)'
        '3 - Regime normal')
      Style.HotTrack = False
      TabOrder = 4
      Width = 280
    end
    object edtTelefone: TcxTextEdit
      Left = 24
      Top = 150
      Properties.MaxLength = 15
      Style.HotTrack = False
      TabOrder = 5
      Width = 140
    end
    object edtEmail: TcxTextEdit
      Left = 180
      Top = 150
      Properties.CharCase = ecLowerCase
      Properties.MaxLength = 100
      Style.HotTrack = False
      TabOrder = 6
      Width = 400
    end
    object edtLogradouro: TcxTextEdit
      Left = 24
      Top = 230
      Properties.CharCase = ecUpperCase
      Properties.MaxLength = 60
      Style.HotTrack = False
      TabOrder = 7
      Width = 500
    end
    object edtNumero: TcxTextEdit
      Left = 540
      Top = 230
      Properties.MaxLength = 60
      Style.HotTrack = False
      TabOrder = 8
      Width = 90
    end
    object edtComplemento: TcxTextEdit
      Left = 24
      Top = 280
      Properties.CharCase = ecUpperCase
      Properties.MaxLength = 60
      Style.HotTrack = False
      TabOrder = 9
      Width = 300
    end
    object edtBairro: TcxTextEdit
      Left = 340
      Top = 280
      Properties.CharCase = ecUpperCase
      Properties.MaxLength = 60
      Style.HotTrack = False
      TabOrder = 10
      Width = 300
    end
    object edtCodigoMunicipio: TcxMaskEdit
      Left = 24
      Top = 330
      Properties.EditMask = '0000000;0;_'
      Style.HotTrack = False
      TabOrder = 11
      Width = 110
    end
    object edtMunicipio: TcxTextEdit
      Left = 150
      Top = 330
      Properties.CharCase = ecUpperCase
      Properties.MaxLength = 60
      Style.HotTrack = False
      TabOrder = 12
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
      TabOrder = 13
      Width = 70
    end
    object edtCEP: TcxMaskEdit
      Left = 552
      Top = 330
      Properties.EditMask = '00000-000;0;_'
      Style.HotTrack = False
      TabOrder = 14
      Width = 100
    end
    object edtSerieNFe: TcxSpinEdit
      Left = 24
      Top = 410
      Properties.MaxValue = 889.000000000000000000
      Style.HotTrack = False
      TabOrder = 15
      Value = 1
      Width = 80
    end
    object edtProximoNFe: TcxSpinEdit
      Left = 120
      Top = 410
      Properties.MaxValue = 999999999.000000000000000000
      Properties.MinValue = 1.000000000000000000
      Style.HotTrack = False
      TabOrder = 16
      Value = 1
      Width = 110
    end
    object edtSerieNFCe: TcxSpinEdit
      Left = 246
      Top = 410
      Properties.MaxValue = 889.000000000000000000
      Style.HotTrack = False
      TabOrder = 17
      Value = 1
      Width = 80
    end
    object edtProximoNFCe: TcxSpinEdit
      Left = 342
      Top = 410
      Properties.MaxValue = 999999999.000000000000000000
      Properties.MinValue = 1.000000000000000000
      Style.HotTrack = False
      TabOrder = 18
      Value = 1
      Width = 110
    end
    object lblCertificado: TcxLabel
      Left = 12
      Top = 470
      Caption = 'Certificado'
      Properties.WordWrap = True
      Transparent = True
      Width = 776
    end
    object btnSalvar: TcxButton
      Left = 576
      Top = 560
      Width = 100
      Height = 28
      Caption = 'Salvar'
      Default = True
      TabOrder = 19
      OnClick = btnSalvarClick
    end
    object btnFechar: TcxButton
      Left = 682
      Top = 560
      Width = 100
      Height = 28
      Cancel = True
      Caption = 'Fechar'
      ModalResult = 2
      TabOrder = 20
    end
    object lcEmitenteGroup_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      Hidden = True
      ShowBorder = False
      Index = -1
    end
    object grpDados: TdxLayoutGroup
      Parent = lcEmitenteGroup_Root
      CaptionOptions.Text = 'Dados da empresa'
      Index = 0
    end
    object grpDados1: TdxLayoutGroup
      Parent = grpDados
      CaptionOptions.Visible = False
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 0
    end
    object liRazaoSocial: TdxLayoutItem
      Parent = grpDados1
      AlignHorz = ahClient
      CaptionOptions.Text = 'Raz'#227'o social'
      CaptionOptions.Layout = clTop
      Control = edtRazaoSocial
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 400
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liNomeFantasia: TdxLayoutItem
      Parent = grpDados1
      AlignHorz = ahClient
      CaptionOptions.Text = 'Nome fantasia'
      CaptionOptions.Layout = clTop
      Control = edtNomeFantasia
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 300
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
    object liCNPJ: TdxLayoutItem
      Parent = grpDados2
      CaptionOptions.Text = 'CNPJ'
      CaptionOptions.Layout = clTop
      Control = edtCNPJ
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 140
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liIE: TdxLayoutItem
      Parent = grpDados2
      CaptionOptions.Text = 'Inscri'#231#227'o estadual'
      CaptionOptions.Layout = clTop
      Control = edtIE
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 140
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liCRT: TdxLayoutItem
      Parent = grpDados2
      AlignHorz = ahClient
      CaptionOptions.Text = 'Regime tribut'#225'rio (CRT)'
      CaptionOptions.Layout = clTop
      Control = cbCRT
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 280
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object grpDados3: TdxLayoutGroup
      Parent = grpDados
      CaptionOptions.Visible = False
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 2
    end
    object liTelefone: TdxLayoutItem
      Parent = grpDados3
      CaptionOptions.Text = 'Telefone'
      CaptionOptions.Layout = clTop
      Control = edtTelefone
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 140
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liEmail: TdxLayoutItem
      Parent = grpDados3
      AlignHorz = ahClient
      CaptionOptions.Text = 'E-mail'
      CaptionOptions.Layout = clTop
      Control = edtEmail
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 400
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object grpEndereco: TdxLayoutGroup
      Parent = lcEmitenteGroup_Root
      CaptionOptions.Text = 'Endere'#231'o'
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
    object grpNumeracao: TdxLayoutGroup
      Parent = lcEmitenteGroup_Root
      CaptionOptions.Text = 'Numera'#231#227'o'
      LayoutDirection = ldHorizontal
      Index = 2
    end
    object liSerieNFe: TdxLayoutItem
      Parent = grpNumeracao
      CaptionOptions.Text = 'S'#233'rie NF-e'
      CaptionOptions.Layout = clTop
      Control = edtSerieNFe
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 80
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liProximoNFe: TdxLayoutItem
      Parent = grpNumeracao
      CaptionOptions.Text = 'Pr'#243'ximo n'#186' NF-e'
      CaptionOptions.Layout = clTop
      Control = edtProximoNFe
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 110
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liSerieNFCe: TdxLayoutItem
      Parent = grpNumeracao
      CaptionOptions.Text = 'S'#233'rie NFC-e'
      CaptionOptions.Layout = clTop
      Control = edtSerieNFCe
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 80
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object liProximoNFCe: TdxLayoutItem
      Parent = grpNumeracao
      CaptionOptions.Text = 'Pr'#243'ximo n'#186' NFC-e'
      CaptionOptions.Layout = clTop
      Control = edtProximoNFCe
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 110
      ControlOptions.ShowBorder = False
      Index = 3
    end
    object liCertificado: TdxLayoutItem
      Parent = lcEmitenteGroup_Root
      AlignHorz = ahClient
      CaptionOptions.Visible = False
      Control = lblCertificado
      ControlOptions.OriginalHeight = 38
      ControlOptions.OriginalWidth = 776
      ControlOptions.ShowBorder = False
      Index = 3
    end
    object grpBotoes: TdxLayoutGroup
      Parent = lcEmitenteGroup_Root
      AlignHorz = ahRight
      AlignVert = avBottom
      CaptionOptions.Visible = False
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 4
    end
    object liSalvar: TdxLayoutItem
      Parent = grpBotoes
      CaptionOptions.Visible = False
      Control = btnSalvar
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
