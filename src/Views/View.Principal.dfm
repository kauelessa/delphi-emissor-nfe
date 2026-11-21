object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  Caption = 'Emissor NF-e / NFC-e'
  ClientHeight = 530
  ClientWidth = 780
  Color = clBtnFace
  Constraints.MinHeight = 570
  Constraints.MinWidth = 760
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 15
  object sbPrincipal: TdxStatusBar
    Left = 0
    Top = 506
    Width = 780
    Height = 24
    Panels = <
      item
        PanelStyleClassName = 'TdxStatusBarTextPanelStyle'
        Width = 340
      end
      item
        PanelStyleClassName = 'TdxStatusBarTextPanelStyle'
      end>
    PaintStyle = stpsUseLookAndFeel
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clDefault
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
  end
  object lcPrincipal: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 780
    Height = 506
    Align = alClient
    TabOrder = 0
    object lblTitulo: TcxLabel
      Left = 12
      Top = 12
      Caption = 'Emissor de NF-e e NFC-e'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -24
      Style.Font.Name = 'Segoe UI'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object lblAmbiente: TcxLabel
      Left = 12
      Top = 52
      Caption = 'Ambiente'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clGreen
      Style.Font.Height = -15
      Style.Font.Name = 'Segoe UI'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object btnNFCe: TcxButton
      Left = 24
      Top = 110
      Width = 170
      Height = 60
      Caption = 'Emitir NFC-e (F2)'
      TabOrder = 0
      OnClick = btnNFCeClick
    end
    object btnNFe: TcxButton
      Left = 200
      Top = 110
      Width = 170
      Height = 60
      Caption = 'Emitir NF-e (F3)'
      TabOrder = 1
      OnClick = btnNFeClick
    end
    object btnNotas: TcxButton
      Left = 376
      Top = 110
      Width = 170
      Height = 60
      Caption = 'Notas emitidas (F4)'
      TabOrder = 2
      OnClick = btnNotasClick
    end
    object btnClientes: TcxButton
      Left = 24
      Top = 210
      Width = 170
      Height = 50
      Caption = 'Clientes'
      TabOrder = 3
      OnClick = btnClientesClick
    end
    object btnProdutos: TcxButton
      Left = 200
      Top = 210
      Width = 170
      Height = 50
      Caption = 'Produtos'
      TabOrder = 4
      OnClick = btnProdutosClick
    end
    object btnFormasPagamento: TcxButton
      Left = 376
      Top = 210
      Width = 170
      Height = 50
      Caption = 'Formas de pagamento'
      TabOrder = 5
      OnClick = btnFormasPagamentoClick
    end
    object btnEmitente: TcxButton
      Left = 552
      Top = 210
      Width = 170
      Height = 50
      Caption = 'Emitente'
      TabOrder = 6
      OnClick = btnEmitenteClick
    end
    object btnStatusSefaz: TcxButton
      Left = 24
      Top = 300
      Width = 170
      Height = 50
      Caption = 'Status da SEFAZ'
      TabOrder = 7
      OnClick = btnStatusSefazClick
    end
    object btnInutilizar: TcxButton
      Left = 200
      Top = 300
      Width = 170
      Height = 50
      Caption = 'Inutilizar numera'#231#227'o'
      TabOrder = 8
      OnClick = btnInutilizarClick
    end
    object btnSair: TcxButton
      Left = 650
      Top = 400
      Width = 110
      Height = 30
      Caption = 'Sair'
      TabOrder = 9
      OnClick = btnSairClick
    end
    object lcPrincipalGroup_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      Hidden = True
      ShowBorder = False
      Index = -1
    end
    object liTitulo: TdxLayoutItem
      Parent = lcPrincipalGroup_Root
      CaptionOptions.Visible = False
      Control = lblTitulo
      ControlOptions.OriginalHeight = 32
      ControlOptions.OriginalWidth = 300
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liAmbiente: TdxLayoutItem
      Parent = lcPrincipalGroup_Root
      CaptionOptions.Visible = False
      Control = lblAmbiente
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 300
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object grpEmissao: TdxLayoutGroup
      Parent = lcPrincipalGroup_Root
      CaptionOptions.Text = 'Emiss'#227'o'
      LayoutDirection = ldHorizontal
      Index = 2
    end
    object liNFCe: TdxLayoutItem
      Parent = grpEmissao
      CaptionOptions.Visible = False
      Control = btnNFCe
      ControlOptions.OriginalHeight = 60
      ControlOptions.OriginalWidth = 170
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liNFe: TdxLayoutItem
      Parent = grpEmissao
      CaptionOptions.Visible = False
      Control = btnNFe
      ControlOptions.OriginalHeight = 60
      ControlOptions.OriginalWidth = 170
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liNotas: TdxLayoutItem
      Parent = grpEmissao
      CaptionOptions.Visible = False
      Control = btnNotas
      ControlOptions.OriginalHeight = 60
      ControlOptions.OriginalWidth = 170
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object grpCadastros: TdxLayoutGroup
      Parent = lcPrincipalGroup_Root
      CaptionOptions.Text = 'Cadastros'
      LayoutDirection = ldHorizontal
      Index = 3
    end
    object liClientes: TdxLayoutItem
      Parent = grpCadastros
      CaptionOptions.Visible = False
      Control = btnClientes
      ControlOptions.OriginalHeight = 50
      ControlOptions.OriginalWidth = 170
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liProdutos: TdxLayoutItem
      Parent = grpCadastros
      CaptionOptions.Visible = False
      Control = btnProdutos
      ControlOptions.OriginalHeight = 50
      ControlOptions.OriginalWidth = 170
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liFormasPagamento: TdxLayoutItem
      Parent = grpCadastros
      CaptionOptions.Visible = False
      Control = btnFormasPagamento
      ControlOptions.OriginalHeight = 50
      ControlOptions.OriginalWidth = 170
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object liEmitente: TdxLayoutItem
      Parent = grpCadastros
      CaptionOptions.Visible = False
      Control = btnEmitente
      ControlOptions.OriginalHeight = 50
      ControlOptions.OriginalWidth = 170
      ControlOptions.ShowBorder = False
      Index = 3
    end
    object grpSefaz: TdxLayoutGroup
      Parent = lcPrincipalGroup_Root
      CaptionOptions.Text = 'SEFAZ'
      LayoutDirection = ldHorizontal
      Index = 4
    end
    object liStatusSefaz: TdxLayoutItem
      Parent = grpSefaz
      CaptionOptions.Visible = False
      Control = btnStatusSefaz
      ControlOptions.OriginalHeight = 50
      ControlOptions.OriginalWidth = 170
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liInutilizar: TdxLayoutItem
      Parent = grpSefaz
      CaptionOptions.Visible = False
      Control = btnInutilizar
      ControlOptions.OriginalHeight = 50
      ControlOptions.OriginalWidth = 170
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liSair: TdxLayoutItem
      Parent = lcPrincipalGroup_Root
      AlignHorz = ahRight
      AlignVert = avBottom
      CaptionOptions.Visible = False
      Control = btnSair
      ControlOptions.OriginalHeight = 30
      ControlOptions.OriginalWidth = 110
      ControlOptions.ShowBorder = False
      Index = 5
    end
  end
  object skinController: TdxSkinController
    NativeStyle = False
    SkinName = 'WXI'
    Left = 700
    Top = 16
  end
end
