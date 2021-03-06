object FrmMain: TFrmMain
  Left = 272
  Top = 133
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 169
  ClientWidth = 306
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 12
  object MemoLog: TMemo
    Left = 0
    Top = 136
    Width = 306
    Height = 16
    Align = alClient
    ScrollBars = ssHorizontal
    TabOrder = 0
    OnChange = MemoLogChange
  end
  object Panel: TPanel
    Left = 0
    Top = 0
    Width = 306
    Height = 136
    Align = alTop
    BevelOuter = bvNone
    Caption = ' '
    TabOrder = 1
    object LbHold: TLabel
      Left = 123
      Top = 11
      Width = 6
      Height = 12
      Caption = ' '
    end
    object LbLack: TLabel
      Left = 225
      Top = 38
      Width = 18
      Height = 12
      Caption = '0/0'
    end
    object Label2: TLabel
      Left = 230
      Top = 13
      Width = 36
      Height = 12
      Caption = 'Label2'
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 152
    Width = 306
    Height = 17
    Panels = <
      item
        Alignment = taCenter
        Text = '7100'
        Width = 50
      end
      item
        Alignment = taCenter
        Text = #26410#36830#25509
        Width = 60
      end
      item
        Alignment = taCenter
        Text = '0/0'
        Width = 70
      end
      item
        Width = 50
      end>
  end
  object SendTimer: TTimer
    Enabled = False
    Interval = 3000
    OnTimer = SendTimerTimer
    Left = 72
    Top = 16
  end
  object ClientSocket: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 0
    OnConnect = ClientSocketConnect
    OnDisconnect = ClientSocketDisconnect
    OnRead = ClientSocketRead
    OnError = ClientSocketError
    Left = 8
    Top = 16
  end
  object Timer: TTimer
    OnTimer = TimerTimer
    Left = 104
    Top = 16
  end
  object DecodeTimer: TTimer
    Interval = 1
    OnTimer = DecodeTimerTimer
    Left = 144
    Top = 16
  end
  object MainMenu: TMainMenu
    Left = 220
    Top = 68
    object MENU_CONTROL: TMenuItem
      Caption = #25511#21046'(&C)'
      object MENU_CONTROL_START: TMenuItem
        Caption = #21551#21160'(&S)'
        OnClick = MENU_CONTROL_STARTClick
      end
      object MENU_CONTROL_STOP: TMenuItem
        Caption = #20572#27490'(&T)'
        OnClick = MENU_CONTROL_STOPClick
      end
      object MENU_CONTROL_RECONNECT: TMenuItem
        Caption = #37325#26032#36830#25509'(&R)'
        OnClick = MENU_CONTROL_RECONNECTClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object MENU_CONTROL_CLEAELOG: TMenuItem
        Caption = #28165#38500#26085#24535'(&C)'
        ShortCut = 16451
        OnClick = MENU_CONTROL_CLEAELOGClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object MENU_CONTROL_EXIT: TMenuItem
        Caption = #36864#20986'(&X)'
        ShortCut = 16472
        OnClick = MENU_CONTROL_EXITClick
      end
    end
    object MENU_VIEW: TMenuItem
      Caption = #26174#31034'(&V)'
      Visible = False
      object MENU_VIEW_LOGMSG: TMenuItem
        Caption = 'View Msg Logs'
        ShortCut = 16460
        OnClick = MENU_VIEW_LOGMSGClick
      end
    end
    object MENU_OPTION: TMenuItem
      Caption = #36873#39033'(&O)'
      object MENU_OPTION_GENERAL: TMenuItem
        Caption = #22522#26412#35774#32622'(&G)'
        OnClick = MENU_OPTION_GENERALClick
      end
      object MENU_OPTION_IPFILTER: TMenuItem
        Caption = #23433#20840#36807#28388'(&F)'
        OnClick = MENU_OPTION_IPFILTERClick
      end
    end
    object A1: TMenuItem
      Caption = #20851#20110'(&A)'
      object N3: TMenuItem
        Caption = #36719#20214#29256#26435'(&V)'
      end
    end
  end
  object StartTimer: TTimer
    Interval = 200
    OnTimer = StartTimerTimer
    Left = 180
    Top = 16
  end
  object ServerSocket: TServerSocket
    Active = False
    Port = 0
    ServerType = stNonBlocking
    OnClientConnect = ServerSocketClientConnect
    OnClientDisconnect = ServerSocketClientDisconnect
    OnClientRead = ServerSocketClientRead
    OnClientError = ServerSocketClientError
    Left = 40
    Top = 16
  end
  object CnTrayIcon: TCnTrayIcon
    AutoHide = True
    Hint = #24080#21495#30331#38470#32593#20851
    Icon.Data = {
      0000010001002020040000000000E80200001600000028000000200000004000
      0000010004000000000000020000000000000000000000000000000000000000
      000000008000008000000080800080000000800080008080000080808000C0C0
      C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
      00B3111111111111000000000000000000BBB333333333110000000000000000
      008888B333333331000000000000000000033333333331100000000000000000
      000888888BBBBB10000000000000000000000333333333100000000000000000
      000008BBBB3B10000444440000000000000008BBBB3310044676764400000000
      00000888BB3310476767667640000000000000BBBB3372267676676764000000
      000000BBBB3372777767627674000000000000888BB377777772226766400000
      0000000BBBB3377777722276764000000000000BBBB337777222226766400000
      0000000888BB37877222222666400000000000008BBB33777722772222400000
      000000008BBB337F777227222240000000000000888BB378F777222224000000
      000000000BBBB3377772222224000000000000000888B3372777222240000000
      000000000088BB373277772400000000000000000088BB337222220000000000
      0000000000088BB370000000000000000000000000088BB33100000000000000
      000000000000BBB333100000000000000B3333333333BBB33310000000000000
      0BB3333333333BBB33300000000000000BBB3333333BBBBBB330000000000000
      08BBBBBBBBBBB88BBB3000000000000008B8888888888888BB30000000000000
      08888888888888888BB00000000000000000000000000000000000000000FC00
      0FFFFC000FFFFC000FFFFE001FFFFE001FFFFF801FFFFF80783FFF80600FFF80
      4007FFC00003FFC00003FFC00001FFE00001FFE00001FFE00001FFF00001FFF0
      0001FFF00003FFF80003FFF80007FFFC000FFFFC003FFFFE07FFFFFE03FFFFFF
      01FFF80001FFF80001FFF80001FFF80001FFF80001FFF80001FFFFFFFFFF}
    PopupMenu = PopupMenu
    UseAppIcon = True
    OnDblClick = CnTrayIconDblClick
    Left = 188
    Top = 68
  end
  object PopupMenu: TPopupMenu
    Left = 160
    Top = 68
  end
end
