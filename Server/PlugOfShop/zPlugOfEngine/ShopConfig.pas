unit ShopConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, ComCtrls, EngineAPI, EngineType;

type
  TFrmShopItem = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    ListViewItemList: TListView;
    ListBoxItemList: TListBox;
    Label1: TLabel;
    EditShopItemName: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    ButtonChgShopItem: TButton;
    ButtonDelShopItem: TButton;
    SpinEditPrice: TSpinEdit;
    Memo1: TMemo;
    ButtonAddShopItem: TButton;
    ButtonLoadShopItemList: TButton;
    ButtonSaveShopItemList: TButton;
    procedure ListViewItemListClick(Sender: TObject);
    procedure ButtonChgShopItemClick(Sender: TObject);
    procedure ButtonDelShopItemClick(Sender: TObject);
    procedure ButtonAddShopItemClick(Sender: TObject);
    procedure ListBoxItemListClick(Sender: TObject);
    procedure ButtonSaveShopItemListClick(Sender: TObject);
    procedure ButtonLoadShopItemListClick(Sender: TObject);
  private
    { Private declarations }
    function InListViewItemList(sItemName: string): Boolean;
    procedure RefLoadShopItemList();
  public
    { Public declarations }
    procedure Open();
  end;

var
  FrmShopItem: TFrmShopItem;

implementation
uses PlayShop, HUtil32, PlugShare;
{$R *.dfm}
function TFrmShopItem.InListViewItemList(sItemName: string): Boolean;
var
  I: Integer;
  ListItem: TListItem;
begin
  Result := False;
  ListViewItemList.Items.BeginUpdate;
  try
    for I := 0 to ListViewItemList.Items.Count - 1 do begin
      ListItem := ListViewItemList.Items.Item[I];
      if CompareText(sItemName, ListItem.Caption) = 0 then begin
        Result := True;
        Break;
      end;
    end;
  finally
    ListViewItemList.Items.EndUpdate;
  end;
end;

procedure TFrmShopItem.RefLoadShopItemList();
var
  I: Integer;
  ListItem: TListItem;
  sItemName: string;
  sPrice: string;
  ShopInfo: pTShopInfo;
  sMemo: string;
begin
  ListViewItemList.Clear;
  if g_ShopItemList <> nil then begin
    for I := 0 to g_ShopItemList.Count - 1 do begin
      ShopInfo := pTShopInfo(g_ShopItemList.Items[I]);
      sItemName := ShopInfo.StdItem.szName;
      sPrice := IntToStr(ShopInfo.StdItem.nPrice div 100);
      sMemo := StrPas(@ShopInfo.sIntroduce);
      ListViewItemList.Items.BeginUpdate;
      try
        ListItem := ListViewItemList.Items.Add;
        ListItem.Caption := sItemName;
        ListItem.SubItems.Add(sPrice);
        ListItem.SubItems.Add(sMemo);
      finally
        ListViewItemList.Items.EndUpdate;
      end;
    end;
  end;
end;

procedure TFrmShopItem.Open();
var
  I: Integer;
  StdItem: _LPTOSTDITEM;
  List: Classes.TList;
begin
  ButtonChgShopItem.Enabled := False;
  ButtonDelShopItem.Enabled := False;
  ButtonAddShopItem.Enabled := False;
  ListBoxItemList.Items.Clear;
  List := Classes.TList(TUserEngine_GetStdItemList);
  if List <> nil then begin
    for I := 0 to List.Count - 1 do begin
      StdItem := List.Items[I];
      ListBoxItemList.Items.AddObject(StdItem.szName, TObject(StdItem));
    end;
  end;
  //LoadShopItemList();
  RefLoadShopItemList();
  ShowModal;
end;

procedure TFrmShopItem.ListViewItemListClick(Sender: TObject);
var
  nItemIndex: Integer;
  ListItem: TListItem;
begin
  try
    nItemIndex := ListViewItemList.ItemIndex;
    ListItem := ListViewItemList.Items.Item[nItemIndex];
    EditShopItemName.Text := ListItem.Caption;
    SpinEditPrice.Value := Str_ToInt(ListItem.SubItems.Strings[0], 0);
    Memo1.Text := ListItem.SubItems.Strings[1];
    ButtonChgShopItem.Enabled := True;
    ButtonDelShopItem.Enabled := True;
  except
    ButtonChgShopItem.Enabled := False;
    ButtonDelShopItem.Enabled := False;
  end;
end;

procedure TFrmShopItem.ButtonChgShopItemClick(Sender: TObject);
var
  nItemIndex: Integer;
  ListItem: TListItem;
begin
  try
    nItemIndex := ListViewItemList.ItemIndex;
    ListItem := ListViewItemList.Items.Item[nItemIndex];
    ListItem.SubItems.Strings[0] := IntToStr(SpinEditPrice.Value);
    ListItem.SubItems.Strings[1] := Trim(Memo1.Text);
  except
  end;
end;

procedure TFrmShopItem.ButtonDelShopItemClick(Sender: TObject);
begin
  ListViewItemList.Items.BeginUpdate;
  try
    ListViewItemList.DeleteSelected;
  finally
    ListViewItemList.Items.EndUpdate;
  end;
end;

procedure TFrmShopItem.ButtonAddShopItemClick(Sender: TObject);
var
  ListItem: TListItem;
  sItemName: string;
  sPrice: string;
  sMemo: string;
begin
  sItemName := Trim(EditShopItemName.Text);
  sPrice := IntToStr(SpinEditPrice.Value);
  sMemo := Trim(Memo1.Text);
  if sItemName = '' then begin
    Application.MessageBox('请选择你要添加的商品！！！', '提示信息', MB_ICONQUESTION);
    Exit;
  end;
  if sMemo = '' then begin
    Application.MessageBox('请输入商品描述！！！', '提示信息', MB_ICONQUESTION);
    Exit;
  end;
  if InListViewItemList(sItemName) then begin
    Application.MessageBox('你要添加的商品已经存在，请选择其他商品！！！', '提示信息', MB_ICONQUESTION);
    Exit;
  end;
  ListViewItemList.Items.BeginUpdate;
  try
    ListItem := ListViewItemList.Items.Add;
    ListItem.Caption := sItemName;
    ListItem.SubItems.Add(sPrice);
    ListItem.SubItems.Add(sMemo);
  finally
    ListViewItemList.Items.EndUpdate;
  end;
end;

procedure TFrmShopItem.ListBoxItemListClick(Sender: TObject);
var
  nItemIndex: Integer;
begin
  try
    nItemIndex := ListBoxItemList.ItemIndex;
    EditShopItemName.Text := ListBoxItemList.Items.Strings[nItemIndex];
    ButtonAddShopItem.Enabled := True;
  except
    ButtonAddShopItem.Enabled := False;
  end;
end;

procedure TFrmShopItem.ButtonSaveShopItemListClick(Sender: TObject);
var
  I: Integer;
  ListItem: TListItem;
  SaveList: Classes.TStringList;
  sLineText: string;
  sFileName: string;
  sItemName: string;
  sPrice: string;
  sMemo: string;
begin
  ButtonSaveShopItemList.Enabled := False;
  sFileName := '.\BuyItemList.txt';
  SaveList := Classes.TStringList.Create();
  SaveList.Add(';引擎插件商铺配置文件');
  SaveList.Add(';物品名称'#9'出售价格'#9'描述');
  ListViewItemList.Items.BeginUpdate;
  try
    for I := 0 to ListViewItemList.Items.Count - 1 do begin
      ListItem := ListViewItemList.Items.Item[I];
      sItemName := ListItem.Caption;
      sPrice := ListItem.SubItems.Strings[0];
      sMemo := ListItem.SubItems.Strings[1];
      sLineText := sItemName + #9 + sPrice + #9 + sMemo;
      SaveList.Add(sLineText);
    end;
  finally
    ListViewItemList.Items.EndUpdate;
  end;
  SaveList.SaveToFile(sFileName);
  SaveList.Free;
  Application.MessageBox('保存完成！！！', '提示信息', MB_ICONQUESTION);
  ButtonSaveShopItemList.Enabled := True;
end;

procedure TFrmShopItem.ButtonLoadShopItemListClick(Sender: TObject);
begin
  ButtonLoadShopItemList.Enabled := False;
  LoadShopItemList();
  RefLoadShopItemList();
  Application.MessageBox('重新加载商列表完成！！！', '提示信息', MB_ICONQUESTION);
  ButtonLoadShopItemList.Enabled := True;
end;

end.

