unit GateShare;

interface
uses
  Windows, SysUtils, Classes, JSocket, WinSock, SyncObjs, IniFiles, Grobal2, Common;
const
  g_sVersion = '程序版本: 1.00 Build 20060910';
  g_sUpDateTime = '更新日期: 2006/09/12';
  g_sProgram = '程序制作: 叶随风飘 QQ:240621028';
  g_sWebSite = '官方网站: http://www.51ggame.com';
  GATEMAXSESSION = 1000;
  MSGMAXLENGTH = 20000;
  SENDCHECKSIZE = 512;
  SENDCHECKSIZEMAX = 2048;
type
  TGList = class(TList)
  private
    GLock: TRTLCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Lock;
    procedure UnLock;
  end;

  TBlockIPMethod = (mDisconnect, mBlock, mBlockList);
  TSockaddr = record
    nIPaddr: Integer;
    dwStartAttackTick: LongWord;
    nAttackCount: Integer;
  end;
  pTSockaddr = ^TSockaddr;

  TSessionInfo = record
    Socket: TCustomWinSocket; //45AA8C
    sSocData: string; //45AA90
    sSendData: string; //45AA94
    nUserListIndex: Integer; //45AA98
    nPacketIdx: Integer; //45AA9C
    nPacketErrCount: Integer; //45AAA0  //数据包序号重复计数（客户端用封包发送数据检测）
    boStartLogon: Boolean; //45AAA4
    boSendLock: Boolean; //45AAA5
    boOverNomSize: Boolean;
    nOverNomSizeCount: ShortInt;
    dwSendLatestTime: LongWord; //45AAA8
    nCheckSendLength: Integer; //45AAAC
    boSendAvailable: Boolean; //45AAB0
    boSendCheck: Boolean; //45AAB1
    dwTimeOutTime: LongWord; //0x28
    nReceiveLength: Integer; //45AAB8
    dwReceiveLengthTick: LongWord;
    dwReceiveTick: LongWord; //45AABC Tick
    nSckHandle: Integer; //45AAC0
    sRemoteAddr: string; //45AAC4
    dwSayMsgTick: LongWord; //发言间隔控制
    dwHitTick: LongWord; //攻击时间
  end;

  pTSessionInfo = ^TSessionInfo;
  TSendUserData = record
    nSocketIdx: Integer; //0x00
    nSocketHandle: Integer; //0x04
    sMsg: string; //0x08
  end;
  pTSendUserData = ^TSendUserData;
procedure AddMainLogMsg(Msg: string; nLevel: Integer);
procedure LoadAbuseFile();
procedure LoadBlockIPFile();
procedure SaveBlockIPList();
var
  CS_MainLog: TCriticalSection;
  CS_FilterMsg: TCriticalSection;
  MainLogMsgList: TStringList;
  nShowLogLevel: Integer = 3;
  GateClass: string = 'Server';
  GateName: string = '游戏网关';
  TitleName: string = '飘飘网络';
  ServerAddr: string = '127.0.0.1';
  ServerPort: Integer = 5000;
  GateAddr: string = '0.0.0.0';
  GatePort: Integer = 7200;
  boStarted: Boolean = False;
  boClose: Boolean = False;
  boShowBite: Boolean = True; //显示B 或 KB
  boServiceStart: Boolean = False;
  boGateReady: Boolean = False; //0045AA74 网关是否就绪
  boCheckServerFail: Boolean = False; //网关 <->游戏服务器之间检测是否失败（超时）
  //  dwCheckServerTimeOutTime    :LongWord = 60 * 1000 ;//网关 <->游戏服务器之间检测超时时间长度
  dwCheckServerTimeOutTime: LongWord = 3 * 60 * 1000; //网关 <->游戏服务器之间检测超时时间长度
  AbuseList: TStringList; //004694F4
  SessionArray: array[0..GATEMAXSESSION - 1] of TSessionInfo;
  SessionCount: Integer; //0x32C 连接会话数
  boShowSckData: Boolean; //0x324 是否显示SOCKET接收的信息

  sReplaceWord: string = '*';
  ReviceMsgList: TList; //0x45AA64
  SendMsgList: TList; //0x45AA68
  nCurrConnCount: Integer;
  boSendHoldTimeOut: Boolean;
  dwSendHoldTick: LongWord;
  n45AA80: Integer;
  n45AA84: Integer;
  dwCheckRecviceTick: LongWord;
  dwCheckRecviceMin: LongWord;
  dwCheckRecviceMax: LongWord;

  dwCheckServerTick: LongWord;
  dwCheckServerTimeMin: LongWord;
  dwCheckServerTimeMax: LongWord;
  SocketBuffer: PChar; //45AA5C
  nBuffLen: Integer; //45AA60
  List_45AA58: TList;
  boDecodeMsgLock: Boolean;
  dwProcessReviceMsgTimeLimit: LongWord;
  dwProcessSendMsgTimeLimit: LongWord;

  BlockIPList: TGList; //禁止连接IP列表
  TempBlockIPList: TGList; //临时禁止连接IP列表
  CurrIPaddrList: TGList;
  AttackIPaddrList: TGList; //攻击IP临时列表

  nMaxConnOfIPaddr: Integer = 50;
  nMaxClientPacketSize: Integer = 7000;
  nNomClientPacketSize: Integer = 200;
  dwClientCheckTimeOut: LongWord = 50; {3000}
  nMaxOverNomSizeCount: Integer = 2;
  nMaxClientMsgCount: Integer = 20;
  nCheckServerFail: Integer = 0;
  dwAttackTick: LongWord = 200;
  nAttackCount: Integer = 10;

  BlockMethod: TBlockIPMethod = mDisconnect;
  bokickOverPacketSize: Boolean = True;

  //  nClientSendBlockSize        :Integer = 250; //发送给客户端数据包大小限制
  nClientSendBlockSize: Integer = 1000; //发送给客户端数据包大小限制
  dwClientTimeOutTime: LongWord = 5000; //客户端连接会话超时(指定时间内未有数据传输)
  Conf: TIniFile;
  sConfigFileName: string = '.\RunGate.ini';
  nSayMsgMaxLen: Integer = 70; //发言字符长度
  dwSayMsgTime: LongWord = 1000; //发主间隔时间
  dwHitTime: LongWord = 300; //攻击间隔时间
  dwSessionTimeOutTime: LongWord = 60 * 60 * 1000;


implementation

procedure AddMainLogMsg(Msg: string; nLevel: Integer);
var
  tMsg: string;
begin
  try
    CS_MainLog.Enter;
    if nLevel <= nShowLogLevel then begin
      tMsg := '[' + TimeToStr(Now) + '] ' + Msg;
      MainLogMsgList.Add(tMsg);
    end;
  finally
    CS_MainLog.Leave;
  end;
end;
procedure LoadAbuseFile();
var
  sFileName: string;
begin
  AddMainLogMsg('正在加载文字过滤配置信息...', 4);
  sFileName := '.\WordFilter.txt';
  if FileExists(sFileName) then begin
    try
      CS_FilterMsg.Enter;
      AbuseList.LoadFromFile(sFileName);
    finally
      CS_FilterMsg.Leave;
    end;
  end;
  AddMainLogMsg('文字过滤信息加载完成...', 4);
end;

procedure LoadBlockIPFile();
var
  I: Integer;
  sFileName: string;
  LoadList: TStringList;
  sIPaddr: string;
  nIPaddr: Integer;
  IPaddr: pTSockaddr;
begin
  AddMainLogMsg('正在加载IP过滤配置信息...', 4);
  sFileName := '.\BlockIPList.txt';
  if FileExists(sFileName) then begin
    LoadList := TStringList.Create;
    LoadList.LoadFromFile(sFileName);
    for I := 0 to LoadList.Count - 1 do begin
      sIPaddr := Trim(LoadList.Strings[0]);
      if sIPaddr = '' then Continue;
      nIPaddr := inet_addr(PChar(sIPaddr));
      if nIPaddr = INADDR_NONE then Continue;
      New(IPaddr);
      FillChar(IPaddr^, SizeOf(TSockaddr), 0);
      IPaddr.nIPaddr := nIPaddr;
      BlockIPList.Add(IPaddr);
    end;
    LoadList.Free;
  end;
  AddMainLogMsg('IP过滤配置信息加载完成...', 4);
end;

procedure SaveBlockIPList();
var
  I: Integer;
  SaveList: TStringList;
begin
  SaveList := TStringList.Create;
  for I := 0 to BlockIPList.Count - 1 do begin
    SaveList.Add(StrPas(inet_ntoa(TInAddr(pTSockaddr(BlockIPList.Items[I]).nIPaddr))));
  end;
  SaveList.SaveToFile('.\BlockIPList.txt');
  SaveList.Free;
end;

constructor TGList.Create;
begin
  inherited Create;
  InitializeCriticalSection(GLock);
end;

destructor TGList.Destroy;
begin
  DeleteCriticalSection(GLock);
  inherited;
end;

procedure TGList.Lock;
begin
  EnterCriticalSection(GLock);
end;

procedure TGList.UnLock;
begin
  LeaveCriticalSection(GLock);
end;

initialization
  begin
    Conf := TIniFile.Create(sConfigFileName);
    nShowLogLevel := Conf.ReadInteger(GateClass, 'ShowLogLevel', nShowLogLevel);
    CS_MainLog := TCriticalSection.Create;
    CS_FilterMsg := TCriticalSection.Create;
    MainLogMsgList := TStringList.Create;
    AbuseList := TStringList.Create;
    ReviceMsgList := TList.Create;
    SendMsgList := TList.Create;
    List_45AA58 := TList.Create;
    boShowSckData := False;
  end;

finalization
  begin
    List_45AA58.Free;
    ReviceMsgList.Free;
    SendMsgList.Free;
    AbuseList.Free;
    MainLogMsgList.Free;
    CS_MainLog.Free;
    CS_FilterMsg.Free;
    Conf.Free;
  end;

end.

