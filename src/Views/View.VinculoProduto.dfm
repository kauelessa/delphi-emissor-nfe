object frmVinculoProduto: TfrmVinculoProduto
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Vincular produto da API'
  ClientHeight = 230
  ClientWidth = 560
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 15
  object lcVinculo: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 560
    Height = 230
    Align = alClient
    TabOrder = 0
    object lblInstrucao: TcxLabel
      Left = 12
      Top = 12
      Caption =
        'Este produto do pedido ainda n'#227'o est'#225' ligado a um produto do emi' +
        'ssor. Escolha o produto com os dados fiscais (NCM, CFOP, CST) que' +
        ' ser'#227'o usados na nota.'
      Properties.WordWrap = True
      Transparent = True
      Width = 536
    end
    object lblItemApi: TcxLabel
      Left = 12
      Top = 56
      Caption = 'Produto da API'
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Segoe UI'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cbProduto: TcxComboBox
      Left = 116
      Top = 84
      Properties.DropDownListStyle = lsFixedList
      Properties.DropDownRows = 15
      Properties.IncrementalSearch = True
      Style.HotTrack = False
      TabOrder = 0
      Width = 432
    end
    object lblAviso: TcxLabel
      Left = 12
      Top = 116
      Caption =
        'A escolha fica gravada e ser'#225' usada automaticamente nos pr'#243'ximos' +
        ' pedidos com este produto.'
      Properties.WordWrap = True
      Style.TextColor = clGrayText
      Transparent = True
      Width = 536
    end
    object btnConfirmar: TcxButton
      Left = 342
      Top = 190
      Width = 100
      Height = 28
      Caption = 'Confirmar'
      Default = True
      TabOrder = 1
      OnClick = btnConfirmarClick
    end
    object btnCancelar: TcxButton
      Left = 448
      Top = 190
      Width = 100
      Height = 28
      Cancel = True
      Caption = 'Cancelar'
      ModalResult = 2
      TabOrder = 2
    end
    object lcVinculoGroup_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      Hidden = True
      ShowBorder = False
      Index = -1
    end
    object liInstrucao: TdxLayoutItem
      Parent = lcVinculoGroup_Root
      AlignHorz = ahClient
      CaptionOptions.Visible = False
      Control = lblInstrucao
      ControlOptions.OriginalHeight = 38
      ControlOptions.OriginalWidth = 536
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object liItemApi: TdxLayoutItem
      Parent = lcVinculoGroup_Root
      AlignHorz = ahClient
      CaptionOptions.Visible = False
      Control = lblItemApi
      ControlOptions.OriginalHeight = 19
      ControlOptions.OriginalWidth = 536
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liProduto: TdxLayoutItem
      Parent = lcVinculoGroup_Root
      AlignHorz = ahClient
      CaptionOptions.Text = 'Produto do emissor'
      Control = cbProduto
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 432
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object liAviso: TdxLayoutItem
      Parent = lcVinculoGroup_Root
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Visible = False
      Control = lblAviso
      ControlOptions.OriginalHeight = 38
      ControlOptions.OriginalWidth = 536
      ControlOptions.ShowBorder = False
      Index = 3
    end
    object grpBotoes: TdxLayoutGroup
      Parent = lcVinculoGroup_Root
      AlignHorz = ahRight
      CaptionOptions.Visible = False
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 4
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
