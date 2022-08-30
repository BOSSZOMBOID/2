package kabam.rotmg.messaging.impl
{
   import com.company.assembleegameclient.game.GameSprite;
   import com.company.assembleegameclient.game.events.GuildResultEvent;
   import com.company.assembleegameclient.game.events.NameResultEvent;
   import com.company.assembleegameclient.game.events.ReconnectEvent;
   import com.company.assembleegameclient.map.Map;
   import com.company.assembleegameclient.map.mapoverlay.CharacterStatusText;
   import com.company.assembleegameclient.objects.Container;
   import com.company.assembleegameclient.objects.Engine;
   import com.company.assembleegameclient.objects.FlashDescription;
   import com.company.assembleegameclient.objects.GameObject;
   import com.company.assembleegameclient.objects.Merchant;
   import com.company.assembleegameclient.objects.NameChanger;
   import com.company.assembleegameclient.objects.ObjectLibrary;
   import com.company.assembleegameclient.objects.Player;
   import com.company.assembleegameclient.objects.Portal;
   import com.company.assembleegameclient.objects.Projectile;
   import com.company.assembleegameclient.objects.SellableObject;
   import com.company.assembleegameclient.objects.particles.AOEEffect;
   import com.company.assembleegameclient.objects.particles.BurstEffect;
   import com.company.assembleegameclient.objects.particles.CollapseEffect;
   import com.company.assembleegameclient.objects.particles.ConeBlastEffect;
   import com.company.assembleegameclient.objects.particles.FlowEffect;
   import com.company.assembleegameclient.objects.particles.HealEffect;
   import com.company.assembleegameclient.objects.particles.LightningEffect;
   import com.company.assembleegameclient.objects.particles.LineEffect;
   import com.company.assembleegameclient.objects.particles.NovaEffect;
   import com.company.assembleegameclient.objects.particles.ParticleEffect;
   import com.company.assembleegameclient.objects.particles.PoisonEffect;
   import com.company.assembleegameclient.objects.particles.RingEffect;
   import com.company.assembleegameclient.objects.particles.StreamEffect;
   import com.company.assembleegameclient.objects.particles.TeleportEffect;
   import com.company.assembleegameclient.objects.particles.ThrowEffect;
   import com.company.assembleegameclient.objects.thrown.ThrowProjectileEffect;
   import com.company.assembleegameclient.parameters.Parameters;
   import com.company.assembleegameclient.sound.Music;
   import com.company.assembleegameclient.sound.SoundEffectLibrary;
   import com.company.assembleegameclient.ui.PicView;
   import com.company.assembleegameclient.ui.dialogs.Dialog;
   import com.company.assembleegameclient.ui.panels.GuildInvitePanel;
   import com.company.assembleegameclient.ui.panels.PartyInvitePanel;
   import com.company.assembleegameclient.ui.panels.TradeRequestPanel;
   import com.company.assembleegameclient.util.FreeList;
   import com.company.util.Random;
   import com.hurlant.crypto.rsa.RSAKey;
   import com.hurlant.util.Base64;
   import com.hurlant.util.der.PEM;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.net.FileReference;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import kabam.lib.net.api.MessageMap;
   import kabam.lib.net.api.MessageProvider;
   import kabam.lib.net.impl.Message;
   import kabam.lib.net.impl.SocketServer;
   import kabam.rotmg.BountyBoard.SubscriptionUI.signals.BountyMemberListSendSignal;
   import kabam.rotmg.account.core.Account;
   import kabam.rotmg.classes.model.CharacterClass;
   import kabam.rotmg.classes.model.ClassesModel;
   import kabam.rotmg.constants.GeneralConstants;
   import kabam.rotmg.constants.ItemConstants;
   import kabam.rotmg.core.StaticInjectorContext;
   import kabam.rotmg.core.model.PlayerModel;
   import kabam.rotmg.death.control.HandleDeathSignal;
   import kabam.rotmg.dialogs.control.OpenDialogSignal;
   import kabam.rotmg.game.focus.control.SetGameFocusSignal;
   import kabam.rotmg.game.model.AddSpeechBalloonVO;
   import kabam.rotmg.game.model.AddTextLineVO;
   import kabam.rotmg.game.model.GameModel;
   import kabam.rotmg.game.model.PotionInventoryModel;
   import kabam.rotmg.game.signals.AddSpeechBalloonSignal;
   import kabam.rotmg.game.signals.AddTextLineSignal;
   import kabam.rotmg.maploading.signals.HideMapLoadingSignal;
   import kabam.rotmg.market.signals.MemMarketAddSignal;
   import kabam.rotmg.market.signals.MemMarketBuySignal;
   import kabam.rotmg.market.signals.MemMarketMyOffersSignal;
   import kabam.rotmg.market.signals.MemMarketRemoveSignal;
   import kabam.rotmg.market.signals.MemMarketSearchSignal;
   import kabam.rotmg.messaging.impl.data.ForgeItem;
   import kabam.rotmg.messaging.impl.data.FuelEngine;
   import kabam.rotmg.messaging.impl.data.GroundTileData;
   import kabam.rotmg.messaging.impl.data.ObjectData;
   import kabam.rotmg.messaging.impl.data.ObjectStatusData;
   import kabam.rotmg.messaging.impl.data.StatData;
   import kabam.rotmg.messaging.impl.incoming.AccountList;
   import kabam.rotmg.messaging.impl.incoming.AllyShoot;
   import kabam.rotmg.messaging.impl.incoming.Aoe;
   import kabam.rotmg.messaging.impl.incoming.BuyResult;
   import kabam.rotmg.messaging.impl.incoming.ClientStat;
   import kabam.rotmg.messaging.impl.incoming.CreateSuccess;
   import kabam.rotmg.messaging.impl.incoming.Damage;
   import kabam.rotmg.messaging.impl.incoming.Death;
   import kabam.rotmg.messaging.impl.incoming.EnemyShoot;
   import kabam.rotmg.messaging.impl.incoming.Failure;
   import kabam.rotmg.messaging.impl.incoming.File;
   import kabam.rotmg.messaging.impl.incoming.GlobalNotification;
   import kabam.rotmg.messaging.impl.incoming.Goto;
   import kabam.rotmg.messaging.impl.incoming.GuildResult;
   import kabam.rotmg.messaging.impl.incoming.InvResult;
   import kabam.rotmg.messaging.impl.incoming.InvitedToGuild;
   import kabam.rotmg.messaging.impl.incoming.MapInfo;
   import kabam.rotmg.messaging.impl.incoming.NameResult;
   import kabam.rotmg.messaging.impl.incoming.NewTick;
   import kabam.rotmg.messaging.impl.incoming.Notification;
   import kabam.rotmg.messaging.impl.incoming.Pic;
   import kabam.rotmg.messaging.impl.incoming.Ping;
   import kabam.rotmg.messaging.impl.incoming.PlaySound;
   import kabam.rotmg.messaging.impl.incoming.QuestObjId;
   import kabam.rotmg.messaging.impl.incoming.Reconnect;
   import kabam.rotmg.messaging.impl.incoming.ServerPlayerShoot;
   import kabam.rotmg.messaging.impl.incoming.ShowEffect;
   import kabam.rotmg.messaging.impl.incoming.SwitchMusic;
   import kabam.rotmg.messaging.impl.incoming.Text;
   import kabam.rotmg.messaging.impl.incoming.TradeAccepted;
   import kabam.rotmg.messaging.impl.incoming.TradeChanged;
   import kabam.rotmg.messaging.impl.incoming.TradeDone;
   import kabam.rotmg.messaging.impl.incoming.TradeRequested;
   import kabam.rotmg.messaging.impl.incoming.TradeStart;
   import kabam.rotmg.messaging.impl.incoming.Update;
   import kabam.rotmg.messaging.impl.incoming.bounty.BountyMemberListSend;
   import kabam.rotmg.messaging.impl.incoming.market.MarketAddResult;
   import kabam.rotmg.messaging.impl.incoming.market.MarketBuyResult;
   import kabam.rotmg.messaging.impl.incoming.market.MarketMyOffersResult;
   import kabam.rotmg.messaging.impl.incoming.market.MarketRemoveResult;
   import kabam.rotmg.messaging.impl.incoming.market.MarketSearchResult;
   import kabam.rotmg.messaging.impl.incoming.party.InvitedToParty;
   import kabam.rotmg.messaging.impl.incoming.talisman.TalismanEssenceData;
   import kabam.rotmg.messaging.impl.outgoing.AcceptTrade;
   import kabam.rotmg.messaging.impl.outgoing.Buy;
   import kabam.rotmg.messaging.impl.outgoing.CancelTrade;
   import kabam.rotmg.messaging.impl.outgoing.ChangeGuildRank;
   import kabam.rotmg.messaging.impl.outgoing.ChangeTrade;
   import kabam.rotmg.messaging.impl.outgoing.ChooseName;
   import kabam.rotmg.messaging.impl.outgoing.Create;
   import kabam.rotmg.messaging.impl.outgoing.CreateGuild;
   import kabam.rotmg.messaging.impl.outgoing.EditAccountList;
   import kabam.rotmg.messaging.impl.outgoing.EnemyHit;
   import kabam.rotmg.messaging.impl.outgoing.Escape;
   import kabam.rotmg.messaging.impl.outgoing.ForgeFusion;
   import kabam.rotmg.messaging.impl.outgoing.FuelEngineAction;
   import kabam.rotmg.messaging.impl.outgoing.GotoAck;
   import kabam.rotmg.messaging.impl.outgoing.GroundDamage;
   import kabam.rotmg.messaging.impl.outgoing.GuildInvite;
   import kabam.rotmg.messaging.impl.outgoing.GuildRemove;
   import kabam.rotmg.messaging.impl.outgoing.Hello;
   import kabam.rotmg.messaging.impl.outgoing.InvDrop;
   import kabam.rotmg.messaging.impl.outgoing.InvSwap;
   import kabam.rotmg.messaging.impl.outgoing.JoinGuild;
   import kabam.rotmg.messaging.impl.outgoing.Load;
   import kabam.rotmg.messaging.impl.outgoing.Move;
   import kabam.rotmg.messaging.impl.outgoing.OtherHit;
   import kabam.rotmg.messaging.impl.outgoing.PlayerHit;
   import kabam.rotmg.messaging.impl.outgoing.PlayerShoot;
   import kabam.rotmg.messaging.impl.outgoing.PlayerText;
   import kabam.rotmg.messaging.impl.outgoing.Pong;
   import kabam.rotmg.messaging.impl.outgoing.PotionStorageInteraction;
   import kabam.rotmg.messaging.impl.outgoing.RequestTrade;
   import kabam.rotmg.messaging.impl.outgoing.Reskin;
   import kabam.rotmg.messaging.impl.outgoing.SquareHit;
   import kabam.rotmg.messaging.impl.outgoing.Teleport;
   import kabam.rotmg.messaging.impl.outgoing.UpgradeStat;
   import kabam.rotmg.messaging.impl.outgoing.UseItem;
   import kabam.rotmg.messaging.impl.outgoing.UsePortal;
   import kabam.rotmg.messaging.impl.outgoing.UsePotion;
   import kabam.rotmg.messaging.impl.outgoing.bounty.BountyMemberListRequest;
   import kabam.rotmg.messaging.impl.outgoing.bounty.BountyRequest;
   import kabam.rotmg.messaging.impl.outgoing.market.MarketAdd;
   import kabam.rotmg.messaging.impl.outgoing.market.MarketBuy;
   import kabam.rotmg.messaging.impl.outgoing.market.MarketMyOffers;
   import kabam.rotmg.messaging.impl.outgoing.market.MarketRemove;
   import kabam.rotmg.messaging.impl.outgoing.market.MarketSearch;
   import kabam.rotmg.messaging.impl.outgoing.party.JoinParty;
   import kabam.rotmg.messaging.impl.outgoing.party.PartyInvite;
   import kabam.rotmg.messaging.impl.outgoing.talisman.TalismanEssenceAction;
   import kabam.rotmg.minimap.control.UpdateGameObjectTileSignal;
   import kabam.rotmg.minimap.control.UpdateGroundTileSignal;
   import kabam.rotmg.minimap.model.UpdateGroundTileVO;
   import kabam.rotmg.servers.api.Server;
   import kabam.rotmg.ui.model.Key;
   import kabam.rotmg.ui.model.UpdateGameObjectTileVO;
   import kabam.rotmg.ui.signals.EternalPopUpSignal;
   import kabam.rotmg.ui.signals.LegendaryPopUpSignal;
   import kabam.rotmg.ui.signals.RevengePopUpSignal;
   import kabam.rotmg.ui.signals.ShowKeySignal;
   import kabam.rotmg.ui.signals.ShowKeyUISignal;
   import kabam.rotmg.ui.signals.UpdateBackpackTabSignal;
   import kabam.rotmg.ui.view.FlexibleDialog;
   import org.swiftsuspenders.Injector;
   import robotlegs.bender.framework.api.ILogger;
   
   public class GameServerConnection
   {
      
      public static const FAILURE:int = 0;
      
      public static const CREATE_SUCCESS:int = 1;
      
      public static const CREATE:int = 2;
      
      public static const PLAYERSHOOT:int = 3;
      
      public static const MOVE:int = 4;
      
      public static const PLAYERTEXT:int = 5;
      
      public static const TEXT:int = 6;
      
      public static const SERVERPLAYERSHOOT:int = 7;
      
      public static const DAMAGE:int = 8;
      
      public static const UPDATE:int = 9;
      
      public static const UPDATEACK:int = 10;
      
      public static const NOTIFICATION:int = 11;
      
      public static const NEWTICK:int = 12;
      
      public static const INVSWAP:int = 13;
      
      public static const USEITEM:int = 14;
      
      public static const SHOWEFFECT:int = 15;
      
      public static const HELLO:int = 16;
      
      public static const GOTO:int = 17;
      
      public static const INVDROP:int = 18;
      
      public static const INVRESULT:int = 19;
      
      public static const RECONNECT:int = 20;
      
      public static const PING:int = 21;
      
      public static const PONG:int = 22;
      
      public static const MAPINFO:int = 23;
      
      public static const LOAD:int = 24;
      
      public static const PIC:int = 25;
      
      public static const TELEPORT:int = 27;
      
      public static const USEPORTAL:int = 28;
      
      public static const DEATH:int = 29;
      
      public static const BUY:int = 30;
      
      public static const BUYRESULT:int = 31;
      
      public static const AOE:int = 32;
      
      public static const GROUNDDAMAGE:int = 33;
      
      public static const PLAYERHIT:int = 34;
      
      public static const ENEMYHIT:int = 35;
      
      public static const AOEACK:int = 36;
      
      public static const SHOOTACK:int = 37;
      
      public static const OTHERHIT:int = 38;
      
      public static const SQUAREHIT:int = 39;
      
      public static const GOTOACK:int = 40;
      
      public static const EDITACCOUNTLIST:int = 41;
      
      public static const ACCOUNTLIST:int = 42;
      
      public static const QUESTOBJID:int = 43;
      
      public static const CHOOSENAME:int = 44;
      
      public static const NAMERESULT:int = 45;
      
      public static const CREATEGUILD:int = 46;
      
      public static const GUILDRESULT:int = 47;
      
      public static const GUILDREMOVE:int = 48;
      
      public static const GUILDINVITE:int = 49;
      
      public static const ALLYSHOOT:int = 50;
      
      public static const ENEMYSHOOT:int = 51;
      
      public static const REQUESTTRADE:int = 52;
      
      public static const TRADEREQUESTED:int = 53;
      
      public static const TRADESTART:int = 54;
      
      public static const CHANGETRADE:int = 55;
      
      public static const TRADECHANGED:int = 56;
      
      public static const ACCEPTTRADE:int = 57;
      
      public static const CANCELTRADE:int = 58;
      
      public static const TRADEDONE:int = 59;
      
      public static const TRADEACCEPTED:int = 60;
      
      public static const CLIENTSTAT:int = 61;
      
      public static const ESCAPE:int = 63;
      
      public static const FILE:int = 64;
      
      public static const INVITEDTOGUILD:int = 65;
      
      public static const JOINGUILD:int = 66;
      
      public static const CHANGEGUILDRANK:int = 67;
      
      public static const PLAYSOUND:int = 68;
      
      public static const GLOBAL_NOTIFICATION:int = 69;
      
      public static const RESKIN:int = 70;
      
      public static const UPGRADESTAT:int = 71;
      
      public static const SWITCH_MUSIC:int = 73;
      
      public static const FORGEFUSION:int = 74;
      
      public static const MARKET_SEARCH:int = 75;
      
      public static const MARKET_SEARCH_RESULT:int = 76;
      
      public static const MARKET_BUY:int = 77;
      
      public static const MARKET_BUY_RESULT:int = 78;
      
      public static const MARKET_ADD:int = 79;
      
      public static const MARKET_ADD_RESULT:int = 80;
      
      public static const MARKET_REMOVE:int = 81;
      
      public static const MARKET_REMOVE_RESULT:int = 82;
      
      public static const MARKET_MY_OFFERS:int = 83;
      
      public static const MARKET_MY_OFFERS_RESULT:int = 84;
      
      public static const BOUNTYREQUEST:int = 86;
      
      public static const BOUNTYMEMBERLISTREQUEST:int = 87;
      
      public static const BOUNTYMEMBERLISTSEND:int = 88;
      
      public static const PARTY_INVITE:int = 89;
      
      public static const INVITED_TO_PARTY:int = 90;
      
      public static const JOIN_PARTY:int = 91;
      
      public static const POTION_STORAGE_INTERACTION:int = 92;
      
      public static const POTIONSTORAGEREQUEST:int = 93;
      
      public static const USEPOTION:int = 94;
      
      public static const TALISMAN_ESSENCE_DATA:int = 100;
      
      public static const TALISMAN_ESSENCE_ACTION:int = 101;
      
      public static const ENGINE_FUEL_ACTION:int = 102;
      
      private static const TO_MILLISECONDS:int = 1000;
      
      public static var instance:GameServerConnection;
      
      private static const NORMAL_SPEECH_COLORS:Vector.<uint> = new <uint>[14802908,16777215,5526612];
      
      private static const ENEMY_SPEECH_COLORS:Vector.<uint> = new <uint>[5644060,16549442,13484223];
      
      private static const TELL_SPEECH_COLORS:Vector.<uint> = new <uint>[2493110,61695,13880567];
      
      private static const GUILD_SPEECH_COLORS:Vector.<uint> = new <uint>[4098560,10944349,13891532];
      
      private static const PARTY_SPEECH_COLORS:Vector.<uint> = new <uint>[16753314,16761024,16772846];
       
      
      public var gs_:GameSprite;
      
      public var server_:Server;
      
      public var gameId_:int;
      
      public var createCharacter_:Boolean;
      
      public var charId_:int;
      
      public var keyTime_:int;
      
      public var key_:ByteArray;
      
      public var mapJSON_:String;
      
      public var lastTickId_:int = -1;
      
      public var jitterWatcher_:JitterWatcher = null;
      
      public var serverConnection:SocketServer;
      
      private var messages:MessageProvider;
      
      private var playerId_:int = -1;
      
      private var player:Player;
      
      private var retryConnection_:Boolean = true;
      
      public var outstandingBuy_:OutstandingBuy = null;
      
      private var rand_:Random = null;
      
      private var death:Death;
      
      private var retryTimer_:Timer;
      
      private var delayBeforeReconect:int = 1;
      
      private var addTextLine:AddTextLineSignal;
      
      private var addSpeechBalloon:AddSpeechBalloonSignal;
      
      private var updateGroundTileSignal:UpdateGroundTileSignal;
      
      private var updateGameObjectTileSignal:UpdateGameObjectTileSignal;
      
      private var logger:ILogger;
      
      private var handleDeath:HandleDeathSignal;
      
      private var setGameFocus:SetGameFocusSignal;
      
      private var updateBackpackTab:UpdateBackpackTabSignal;
      
      private var classesModel:ClassesModel;
      
      private var playerModel:PlayerModel;
      
      private var injector:Injector;
      
      private var model:GameModel;
      
      public function GameServerConnection(param1:GameSprite, param2:Server, param3:int, param4:Boolean, param5:int, param6:int, param7:ByteArray, param8:String)
      {
         super();
         this.injector = StaticInjectorContext.getInjector();
         this.addTextLine = this.injector.getInstance(AddTextLineSignal);
         this.addSpeechBalloon = this.injector.getInstance(AddSpeechBalloonSignal);
         this.updateGroundTileSignal = this.injector.getInstance(UpdateGroundTileSignal);
         this.updateGameObjectTileSignal = this.injector.getInstance(UpdateGameObjectTileSignal);
         this.updateBackpackTab = StaticInjectorContext.getInjector().getInstance(UpdateBackpackTabSignal);
         this.logger = this.injector.getInstance(ILogger);
         this.handleDeath = this.injector.getInstance(HandleDeathSignal);
         this.setGameFocus = this.injector.getInstance(SetGameFocusSignal);
         this.classesModel = this.injector.getInstance(ClassesModel);
         this.serverConnection = this.injector.getInstance(SocketServer);
         this.messages = this.injector.getInstance(MessageProvider);
         this.model = this.injector.getInstance(GameModel);
         this.playerModel = this.injector.getInstance(PlayerModel);
         instance = this;
         this.gs_ = param1;
         this.server_ = param2;
         this.gameId_ = param3;
         this.createCharacter_ = param4;
         this.charId_ = param5;
         this.keyTime_ = param6;
         this.key_ = param7;
         this.mapJSON_ = param8;
      }
      
      public static function rsaEncrypt(param1:String) : String
      {
         var _loc2_:RSAKey = PEM.readRSAPublicKey(Parameters.RSA_PUBLIC_KEY);
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeUTFBytes(param1);
         var _loc4_:ByteArray = new ByteArray();
         _loc2_.encrypt(_loc3_,_loc4_,_loc3_.length);
         return Base64.encodeByteArray(_loc4_);
      }
      
      public function disconnect() : void
      {
         this.removeServerConnectionListeners();
         this.unmapMessages();
         this.serverConnection.disconnect();
      }
      
      private function removeServerConnectionListeners() : void
      {
         this.serverConnection.connected.remove(this.onConnected);
         this.serverConnection.closed.remove(this.onClosed);
         this.serverConnection.error.remove(this.onError);
      }
      
      public function connect() : void
      {
         this.addServerConnectionListeners();
         this.mapMessages();
         if(!this.isServerDefined())
         {
            this.gs_.closed.dispatch();
            return;
         }
         this.addTextLine.dispatch(new AddTextLineVO(Parameters.CLIENT_CHAT_NAME,"Connecting to " + this.server_.name));
         this.serverConnection.connect(this.server_.address,this.server_.port);
      }
      
      private function isServerDefined() : Boolean
      {
         var _loc1_:* = this.server_ != null;
         _loc1_ || this.logger.fatal("Unable to connect - no valid server found");
         return _loc1_;
      }
      
      private function addServerConnectionListeners() : void
      {
         this.serverConnection.connected.add(this.onConnected);
         this.serverConnection.closed.add(this.onClosed);
         this.serverConnection.error.add(this.onError);
      }
      
      private function mapMessages() : void
      {
         var _loc1_:MessageMap = this.injector.getInstance(MessageMap);
         _loc1_.map(CREATE).toMessage(Create);
         _loc1_.map(PLAYERSHOOT).toMessage(PlayerShoot);
         _loc1_.map(MOVE).toMessage(Move);
         _loc1_.map(PLAYERTEXT).toMessage(PlayerText);
         _loc1_.map(UPDATEACK).toMessage(Message);
         _loc1_.map(INVSWAP).toMessage(InvSwap);
         _loc1_.map(USEITEM).toMessage(UseItem);
         _loc1_.map(HELLO).toMessage(Hello);
         _loc1_.map(INVDROP).toMessage(InvDrop);
         _loc1_.map(PONG).toMessage(Pong);
         _loc1_.map(LOAD).toMessage(Load);
         _loc1_.map(TELEPORT).toMessage(Teleport);
         _loc1_.map(USEPORTAL).toMessage(UsePortal);
         _loc1_.map(BUY).toMessage(Buy);
         _loc1_.map(PLAYERHIT).toMessage(PlayerHit);
         _loc1_.map(ENEMYHIT).toMessage(EnemyHit);
         _loc1_.map(OTHERHIT).toMessage(OtherHit);
         _loc1_.map(SQUAREHIT).toMessage(SquareHit);
         _loc1_.map(GOTOACK).toMessage(GotoAck);
         _loc1_.map(GROUNDDAMAGE).toMessage(GroundDamage);
         _loc1_.map(CHOOSENAME).toMessage(ChooseName);
         _loc1_.map(CREATEGUILD).toMessage(CreateGuild);
         _loc1_.map(GUILDREMOVE).toMessage(GuildRemove);
         _loc1_.map(GUILDINVITE).toMessage(GuildInvite);
         _loc1_.map(REQUESTTRADE).toMessage(RequestTrade);
         _loc1_.map(CHANGETRADE).toMessage(ChangeTrade);
         _loc1_.map(ACCEPTTRADE).toMessage(AcceptTrade);
         _loc1_.map(CANCELTRADE).toMessage(CancelTrade);
         _loc1_.map(JOINGUILD).toMessage(JoinGuild);
         _loc1_.map(CHANGEGUILDRANK).toMessage(ChangeGuildRank);
         _loc1_.map(EDITACCOUNTLIST).toMessage(EditAccountList);
         _loc1_.map(UPGRADESTAT).toMessage(UpgradeStat);
         _loc1_.map(FORGEFUSION).toMessage(ForgeFusion);
         _loc1_.map(ENGINE_FUEL_ACTION).toMessage(FuelEngineAction);
         _loc1_.map(ESCAPE).toMessage(Escape);
         _loc1_.map(BOUNTYREQUEST).toMessage(BountyRequest);
         _loc1_.map(BOUNTYMEMBERLISTREQUEST).toMessage(BountyMemberListRequest);
         _loc1_.map(BOUNTYMEMBERLISTSEND).toMessage(BountyMemberListSend).toMethod(this.onBountyMembersListGet);
         _loc1_.map(PARTY_INVITE).toMessage(PartyInvite);
         _loc1_.map(INVITED_TO_PARTY).toMessage(InvitedToParty).toMethod(this.onInvitedToParty);
         _loc1_.map(JOIN_PARTY).toMessage(JoinParty);
         _loc1_.map(FAILURE).toMessage(Failure).toMethod(this.onFailure);
         _loc1_.map(CREATE_SUCCESS).toMessage(CreateSuccess).toMethod(this.onCreateSuccess);
         _loc1_.map(TEXT).toMessage(Text).toMethod(this.onText);
         _loc1_.map(SERVERPLAYERSHOOT).toMessage(ServerPlayerShoot).toMethod(this.onServerPlayerShoot);
         _loc1_.map(DAMAGE).toMessage(Damage).toMethod(this.onDamage);
         _loc1_.map(UPDATE).toMessage(Update).toMethod(this.onUpdate);
         _loc1_.map(NOTIFICATION).toMessage(Notification).toMethod(this.onNotification);
         _loc1_.map(GLOBAL_NOTIFICATION).toMessage(GlobalNotification).toMethod(this.onGlobalNotification);
         _loc1_.map(NEWTICK).toMessage(NewTick).toMethod(this.onNewTick);
         _loc1_.map(SHOWEFFECT).toMessage(ShowEffect).toMethod(this.onShowEffect);
         _loc1_.map(GOTO).toMessage(Goto).toMethod(this.onGoto);
         _loc1_.map(INVRESULT).toMessage(InvResult).toMethod(this.onInvResult);
         _loc1_.map(RECONNECT).toMessage(Reconnect).toMethod(this.onReconnect);
         _loc1_.map(PING).toMessage(Ping).toMethod(this.onPing);
         _loc1_.map(MAPINFO).toMessage(MapInfo).toMethod(this.onMapInfo);
         _loc1_.map(PIC).toMessage(Pic).toMethod(this.onPic);
         _loc1_.map(DEATH).toMessage(Death).toMethod(this.onDeath);
         _loc1_.map(BUYRESULT).toMessage(BuyResult).toMethod(this.onBuyResult);
         _loc1_.map(AOE).toMessage(Aoe).toMethod(this.onAoe);
         _loc1_.map(ACCOUNTLIST).toMessage(AccountList).toMethod(this.onAccountList);
         _loc1_.map(QUESTOBJID).toMessage(QuestObjId).toMethod(this.onQuestObjId);
         _loc1_.map(NAMERESULT).toMessage(NameResult).toMethod(this.onNameResult);
         _loc1_.map(GUILDRESULT).toMessage(GuildResult).toMethod(this.onGuildResult);
         _loc1_.map(ALLYSHOOT).toMessage(AllyShoot).toMethod(this.onAllyShoot);
         _loc1_.map(ENEMYSHOOT).toMessage(EnemyShoot).toMethod(this.onEnemyShoot);
         _loc1_.map(TRADEREQUESTED).toMessage(TradeRequested).toMethod(this.onTradeRequested);
         _loc1_.map(TRADESTART).toMessage(TradeStart).toMethod(this.onTradeStart);
         _loc1_.map(TRADECHANGED).toMessage(TradeChanged).toMethod(this.onTradeChanged);
         _loc1_.map(TRADEDONE).toMessage(TradeDone).toMethod(this.onTradeDone);
         _loc1_.map(TRADEACCEPTED).toMessage(TradeAccepted).toMethod(this.onTradeAccepted);
         _loc1_.map(CLIENTSTAT).toMessage(ClientStat).toMethod(this.onClientStat);
         _loc1_.map(FILE).toMessage(File).toMethod(this.onFile);
         _loc1_.map(INVITEDTOGUILD).toMessage(InvitedToGuild).toMethod(this.onInvitedToGuild);
         _loc1_.map(SWITCH_MUSIC).toMessage(SwitchMusic).toMethod(this.onSwitchMusic);
         _loc1_.map(PLAYSOUND).toMessage(PlaySound).toMethod(this.onPlaySound);
         _loc1_.map(MARKET_SEARCH).toMessage(MarketSearch);
         _loc1_.map(MARKET_SEARCH_RESULT).toMessage(MarketSearchResult).toMethod(this.onMarketSearchResult);
         _loc1_.map(MARKET_BUY).toMessage(MarketBuy);
         _loc1_.map(MARKET_BUY_RESULT).toMessage(MarketBuyResult).toMethod(this.onMarketBuyResult);
         _loc1_.map(MARKET_ADD).toMessage(MarketAdd);
         _loc1_.map(MARKET_ADD_RESULT).toMessage(MarketAddResult).toMethod(this.onMarketAddResult);
         _loc1_.map(MARKET_REMOVE).toMessage(MarketRemove);
         _loc1_.map(MARKET_REMOVE_RESULT).toMessage(MarketRemoveResult).toMethod(this.onMarketRemoveResult);
         _loc1_.map(MARKET_MY_OFFERS).toMessage(MarketMyOffers);
         _loc1_.map(MARKET_MY_OFFERS_RESULT).toMessage(MarketMyOffersResult).toMethod(this.onMarketMyOffersResult);
         _loc1_.map(POTION_STORAGE_INTERACTION).toMessage(PotionStorageInteraction);
         _loc1_.map(USEPOTION).toMessage(UsePotion);
         _loc1_.map(TALISMAN_ESSENCE_DATA).toMessage(TalismanEssenceData).toMethod(this.onTalismanEssenceData);
         _loc1_.map(TALISMAN_ESSENCE_ACTION).toMessage(TalismanEssenceAction);
      }
      
      private function unmapMessages() : void
      {
         var _loc1_:MessageMap = this.injector.getInstance(MessageMap);
         _loc1_.unmap(CREATE);
         _loc1_.unmap(PLAYERSHOOT);
         _loc1_.unmap(MOVE);
         _loc1_.unmap(PLAYERTEXT);
         _loc1_.unmap(UPDATEACK);
         _loc1_.unmap(INVSWAP);
         _loc1_.unmap(USEITEM);
         _loc1_.unmap(HELLO);
         _loc1_.unmap(INVDROP);
         _loc1_.unmap(PONG);
         _loc1_.unmap(LOAD);
         _loc1_.unmap(TELEPORT);
         _loc1_.unmap(USEPORTAL);
         _loc1_.unmap(BUY);
         _loc1_.unmap(PLAYERHIT);
         _loc1_.unmap(ENEMYHIT);
         _loc1_.unmap(OTHERHIT);
         _loc1_.unmap(SQUAREHIT);
         _loc1_.unmap(GOTOACK);
         _loc1_.unmap(GROUNDDAMAGE);
         _loc1_.unmap(CHOOSENAME);
         _loc1_.unmap(CREATEGUILD);
         _loc1_.unmap(GUILDREMOVE);
         _loc1_.unmap(GUILDINVITE);
         _loc1_.unmap(REQUESTTRADE);
         _loc1_.unmap(CHANGETRADE);
         _loc1_.unmap(ACCEPTTRADE);
         _loc1_.unmap(CANCELTRADE);
         _loc1_.unmap(JOINGUILD);
         _loc1_.unmap(CHANGEGUILDRANK);
         _loc1_.unmap(EDITACCOUNTLIST);
         _loc1_.unmap(FAILURE);
         _loc1_.unmap(CREATE_SUCCESS);
         _loc1_.unmap(TEXT);
         _loc1_.unmap(SERVERPLAYERSHOOT);
         _loc1_.unmap(DAMAGE);
         _loc1_.unmap(UPDATE);
         _loc1_.unmap(NOTIFICATION);
         _loc1_.unmap(GLOBAL_NOTIFICATION);
         _loc1_.unmap(NEWTICK);
         _loc1_.unmap(SHOWEFFECT);
         _loc1_.unmap(GOTO);
         _loc1_.unmap(INVRESULT);
         _loc1_.unmap(RECONNECT);
         _loc1_.unmap(PING);
         _loc1_.unmap(MAPINFO);
         _loc1_.unmap(PIC);
         _loc1_.unmap(DEATH);
         _loc1_.unmap(BUYRESULT);
         _loc1_.unmap(AOE);
         _loc1_.unmap(ACCOUNTLIST);
         _loc1_.unmap(QUESTOBJID);
         _loc1_.unmap(NAMERESULT);
         _loc1_.unmap(GUILDRESULT);
         _loc1_.unmap(ALLYSHOOT);
         _loc1_.unmap(ENEMYSHOOT);
         _loc1_.unmap(TRADEREQUESTED);
         _loc1_.unmap(TRADESTART);
         _loc1_.unmap(TRADECHANGED);
         _loc1_.unmap(TRADEDONE);
         _loc1_.unmap(TRADEACCEPTED);
         _loc1_.unmap(CLIENTSTAT);
         _loc1_.unmap(FILE);
         _loc1_.unmap(INVITEDTOGUILD);
         _loc1_.unmap(PLAYSOUND);
         _loc1_.unmap(UPGRADESTAT);
         _loc1_.unmap(FORGEFUSION);
         _loc1_.unmap(ENGINE_FUEL_ACTION);
         _loc1_.unmap(ESCAPE);
         _loc1_.unmap(MARKET_SEARCH);
         _loc1_.unmap(MARKET_SEARCH_RESULT);
         _loc1_.unmap(MARKET_BUY);
         _loc1_.unmap(MARKET_BUY_RESULT);
         _loc1_.unmap(MARKET_ADD);
         _loc1_.unmap(MARKET_ADD_RESULT);
         _loc1_.unmap(MARKET_REMOVE);
         _loc1_.unmap(MARKET_REMOVE_RESULT);
         _loc1_.unmap(MARKET_MY_OFFERS);
         _loc1_.unmap(MARKET_MY_OFFERS_RESULT);
         _loc1_.unmap(BOUNTYREQUEST);
         _loc1_.unmap(BOUNTYMEMBERLISTREQUEST);
         _loc1_.unmap(PARTY_INVITE);
         _loc1_.unmap(INVITED_TO_PARTY);
         _loc1_.unmap(JOIN_PARTY);
         _loc1_.unmap(POTION_STORAGE_INTERACTION);
         _loc1_.unmap(SWITCH_MUSIC);
         _loc1_.unmap(TALISMAN_ESSENCE_DATA);
         _loc1_.unmap(TALISMAN_ESSENCE_ACTION);
      }
      
      private function onTalismanEssenceData(param1:TalismanEssenceData) : void
      {
         this.gs_.map.player_.essence_ = param1.essence_;
         this.gs_.map.player_.essenceCap_ = param1.essenceCap_;
         var _loc2_:int = 0;
         while(_loc2_ < param1.talismans_.length)
         {
            this.gs_.map.player_.addTalisman(param1.talismans_[_loc2_]);
            _loc2_++;
         }
      }
      
      private function onSwitchMusic(param1:SwitchMusic) : void
      {
         Music.load(param1.music);
      }
      
      public function getNextDamage(param1:uint, param2:uint) : uint
      {
         return this.rand_.nextIntRange(param1,param2);
      }
      
      public function enableJitterWatcher() : void
      {
         if(this.jitterWatcher_ == null)
         {
            this.jitterWatcher_ = new JitterWatcher();
         }
      }
      
      public function disableJitterWatcher() : void
      {
         if(this.jitterWatcher_ != null)
         {
            this.jitterWatcher_ = null;
         }
      }
      
      public function talismanAction(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:TalismanEssenceAction = this.messages.require(TALISMAN_ESSENCE_ACTION) as TalismanEssenceAction;
         _loc4_.actionType_ = param1;
         _loc4_.type_ = param2;
         _loc4_.amount_ = param3;
         this.serverConnection.sendMessage(_loc4_);
      }
      
      private function create() : void
      {
         var _loc1_:CharacterClass = this.classesModel.getSelected();
         var _loc2_:Create = this.messages.require(CREATE) as Create;
         _loc2_.classType = _loc1_.id;
         _loc2_.skinType = _loc1_.skins.getSelectedSkin().id;
         this.serverConnection.sendMessage(_loc2_);
      }
      
      private function load() : void
      {
         var _loc1_:Load = this.messages.require(LOAD) as Load;
         _loc1_.charId_ = this.charId_;
         this.serverConnection.sendMessage(_loc1_);
      }
      
      public function playerShoot(param1:int, param2:Projectile) : void
      {
         var _loc3_:PlayerShoot = this.messages.require(PLAYERSHOOT) as PlayerShoot;
         _loc3_.time_ = param1;
         _loc3_.bulletId_ = param2.bulletId_;
         _loc3_.containerType_ = param2.containerType_;
         _loc3_.startingPos_.x_ = param2.x_;
         _loc3_.startingPos_.y_ = param2.y_;
         _loc3_.angle_ = param2.angle_;
         this.serverConnection.sendMessage(_loc3_);
      }
      
      public function playerHit(param1:int, param2:int) : void
      {
         var _loc3_:PlayerHit = this.messages.require(PLAYERHIT) as PlayerHit;
         _loc3_.bulletId_ = param1;
         _loc3_.objectId_ = param2;
         this.serverConnection.sendMessage(_loc3_);
      }
      
      public function enemyHit(param1:int, param2:int, param3:int, param4:Boolean, param5:int) : void
      {
         var _loc6_:EnemyHit = this.messages.require(ENEMYHIT) as EnemyHit;
         _loc6_.time_ = param1;
         _loc6_.bulletId_ = param2;
         _loc6_.targetId_ = param3;
         _loc6_.kill_ = param4;
         _loc6_.itemType_ = param5;
         this.serverConnection.sendMessage(_loc6_);
      }
      
      public function otherHit(param1:int, param2:int, param3:int, param4:int) : void
      {
         var _loc5_:OtherHit = this.messages.require(OTHERHIT) as OtherHit;
         _loc5_.time_ = param1;
         _loc5_.bulletId_ = param2;
         _loc5_.objectId_ = param3;
         _loc5_.targetId_ = param4;
         this.serverConnection.sendMessage(_loc5_);
      }
      
      public function squareHit(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:SquareHit = this.messages.require(SQUAREHIT) as SquareHit;
         _loc4_.time_ = param1;
         _loc4_.bulletId_ = param2;
         _loc4_.objectId_ = param3;
         this.serverConnection.sendMessage(_loc4_);
      }
      
      public function groundDamage(param1:int, param2:Number, param3:Number) : void
      {
         var _loc4_:GroundDamage = this.messages.require(GROUNDDAMAGE) as GroundDamage;
         _loc4_.time_ = param1;
         _loc4_.position_.x_ = param2;
         _loc4_.position_.y_ = param3;
         this.serverConnection.sendMessage(_loc4_);
      }
      
      public function playerText(param1:String) : void
      {
         var _loc2_:PlayerText = this.messages.require(PLAYERTEXT) as PlayerText;
         _loc2_.text_ = param1;
         this.serverConnection.sendMessage(_loc2_);
      }
      
      public function invSwap(param1:Player, param2:GameObject, param3:int, param4:int, param5:GameObject, param6:int, param7:int) : Boolean
      {
         if(!this.gs_)
         {
            return false;
         }
         var _loc8_:InvSwap = this.messages.require(INVSWAP) as InvSwap;
         _loc8_.time_ = this.gs_.lastUpdate_;
         _loc8_.position_.x_ = param1.x_;
         _loc8_.position_.y_ = param1.y_;
         _loc8_.slotObject1_.objectId_ = param2.objectId_;
         _loc8_.slotObject1_.slotId_ = param3;
         _loc8_.slotObject1_.objectType_ = param4;
         _loc8_.slotObject2_.objectId_ = param5.objectId_;
         _loc8_.slotObject2_.slotId_ = param6;
         _loc8_.slotObject2_.objectType_ = param7;
         this.serverConnection.sendMessage(_loc8_);
         var _loc9_:int = param2.equipment_[param3];
         param2.equipment_[param3] = param5.equipment_[param6];
         param5.equipment_[param6] = _loc9_;
         var _loc10_:Object = param2.equipData_[param3];
         param2.equipData_[param3] = param5.equipData_[param6];
         param5.equipData_[param6] = _loc10_;
         SoundEffectLibrary.play("inventory_move_item");
         return true;
      }
      
      public function invSwapPotion(param1:Player, param2:GameObject, param3:int, param4:int, param5:GameObject, param6:int, param7:int) : Boolean
      {
         if(!this.gs_)
         {
            return false;
         }
         var _loc8_:InvSwap = this.messages.require(INVSWAP) as InvSwap;
         _loc8_.time_ = this.gs_.lastUpdate_;
         _loc8_.position_.x_ = param1.x_;
         _loc8_.position_.y_ = param1.y_;
         _loc8_.slotObject1_.objectId_ = param2.objectId_;
         _loc8_.slotObject1_.slotId_ = param3;
         _loc8_.slotObject1_.objectType_ = param4;
         _loc8_.slotObject2_.objectId_ = param5.objectId_;
         _loc8_.slotObject2_.slotId_ = param6;
         _loc8_.slotObject2_.objectType_ = param7;
         param2.equipment_[param3] = ItemConstants.NO_ITEM;
         param2.equipData_[param3] = null;
         if(param4 == PotionInventoryModel.HEALTH_POTION_ID)
         {
            ++param1.healthPotionCount_;
         }
         else if(param4 == PotionInventoryModel.MAGIC_POTION_ID)
         {
            ++param1.magicPotionCount_;
         }
         this.serverConnection.sendMessage(_loc8_);
         SoundEffectLibrary.play("inventory_move_item");
         return true;
      }
      
      public function invDrop(param1:GameObject, param2:int, param3:int) : void
      {
         var _loc4_:InvDrop = this.messages.require(INVDROP) as InvDrop;
         _loc4_.slotObject_.objectId_ = param1.objectId_;
         _loc4_.slotObject_.slotId_ = param2;
         _loc4_.slotObject_.objectType_ = param3;
         this.serverConnection.sendMessage(_loc4_);
         if(param2 != PotionInventoryModel.HEALTH_POTION_SLOT && param2 != PotionInventoryModel.MAGIC_POTION_SLOT)
         {
            param1.equipment_[param2] = ItemConstants.NO_ITEM;
         }
      }
      
      public function useItem(param1:int, param2:int, param3:int, param4:int, param5:Number, param6:Number, param7:int) : void
      {
         var _loc8_:UseItem = this.messages.require(USEITEM) as UseItem;
         _loc8_.time_ = param1;
         _loc8_.slotObject_.objectId_ = param2;
         _loc8_.slotObject_.slotId_ = param3;
         _loc8_.slotObject_.objectType_ = param4;
         _loc8_.itemUsePos_.x_ = param5;
         _loc8_.itemUsePos_.y_ = param6;
         _loc8_.useType_ = param7;
         this.serverConnection.sendMessage(_loc8_);
      }
      
      public function useItem_new(param1:GameObject, param2:int) : Boolean
      {
         var _loc3_:int = param1.equipment_[param2];
         var _loc4_:XML = ObjectLibrary.xmlLibrary_[_loc3_];
         var _loc5_:int = Parameters.data_.sellMaxyPots;
         if(_loc4_ && !param1.isPaused() && (_loc4_.hasOwnProperty("Consumable") || _loc4_.hasOwnProperty("InvUse")))
         {
            if(_loc5_ == 1)
            {
               this.applyUseItem(param1,param2,_loc3_,_loc4_,_loc5_);
               SoundEffectLibrary.play("use_potion");
               return true;
            }
            if(_loc5_ == 2)
            {
               this.applyUseItem(param1,param2,_loc3_,_loc4_,_loc5_);
               SoundEffectLibrary.play("use_potion");
               return true;
            }
            this.applyUseItem(param1,param2,_loc3_,_loc4_);
            SoundEffectLibrary.play("use_potion");
            return true;
         }
         SoundEffectLibrary.play("error");
         return false;
      }
      
      public function PotionInteraction(param1:int, param2:int) : void
      {
         var _loc3_:PotionStorageInteraction = this.messages.require(GameServerConnection.POTION_STORAGE_INTERACTION) as PotionStorageInteraction;
         _loc3_.type_ = param1;
         _loc3_.action_ = param2;
         this.serverConnection.sendMessage(_loc3_);
      }
      
      private function applyUseItem(param1:GameObject, param2:int, param3:int, param4:XML, param5:int = 0) : void
      {
         var _loc6_:UseItem = this.messages.require(USEITEM) as UseItem;
         _loc6_.time_ = getTimer();
         _loc6_.slotObject_.objectId_ = param1.objectId_;
         _loc6_.slotObject_.slotId_ = param2;
         _loc6_.slotObject_.objectType_ = param3;
         _loc6_.itemUsePos_.x_ = 0;
         _loc6_.itemUsePos_.y_ = 0;
         _loc6_.sellMaxed_ = param5;
         this.serverConnection.sendMessage(_loc6_);
         if(param4.hasOwnProperty("Consumable"))
         {
            param1.equipment_[param2] = -1;
         }
      }
      
      public function move(param1:int, param2:Player) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Number = -1;
         var _loc6_:Number = -1;
         if(param2 && !param2.isPaused())
         {
            _loc5_ = param2.x_;
            _loc6_ = param2.y_;
         }
         var _loc7_:Move = this.messages.require(MOVE) as Move;
         _loc7_.tickId_ = param1;
         _loc7_.time_ = this.gs_.lastUpdate_;
         _loc7_.newPosition_.x_ = _loc5_;
         _loc7_.newPosition_.y_ = _loc6_;
         var _loc8_:int = this.gs_.moveRecords_.lastClearTime_;
         _loc7_.records_.length = 0;
         if(_loc8_ >= 0 && _loc7_.time_ - _loc8_ > 125)
         {
            _loc3_ = Math.min(10,this.gs_.moveRecords_.records_.length);
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(this.gs_.moveRecords_.records_[_loc4_].time_ >= _loc7_.time_ - 25)
               {
                  break;
               }
               _loc7_.records_.push(this.gs_.moveRecords_.records_[_loc4_]);
               _loc4_++;
            }
         }
         this.gs_.moveRecords_.clear(_loc7_.time_);
         this.serverConnection.sendMessage(_loc7_);
         param2 && param2.onMove();
      }
      
      public function teleport(param1:int) : void
      {
         var _loc2_:Teleport = this.messages.require(TELEPORT) as Teleport;
         _loc2_.objectId_ = param1;
         this.serverConnection.sendMessage(_loc2_);
      }
      
      public function usePortal(param1:int) : void
      {
         var _loc2_:UsePortal = this.messages.require(USEPORTAL) as UsePortal;
         _loc2_.objectId_ = param1;
         this.serverConnection.sendMessage(_loc2_);
      }
      
      public function buy(param1:int, param2:int) : void
      {
         if(this.outstandingBuy_)
         {
            return;
         }
         var _loc3_:SellableObject = this.gs_.map.goDict_[param1];
         if(_loc3_ == null)
         {
            return;
         }
         this.outstandingBuy_ = new OutstandingBuy(_loc3_.soldObjectInternalName(),_loc3_.price_,_loc3_.currency_);
         var _loc4_:Buy = this.messages.require(BUY) as Buy;
         _loc4_.objectId_ = param1;
         this.serverConnection.sendMessage(_loc4_);
      }
      
      public function gotoAck(param1:int) : void
      {
         var _loc2_:GotoAck = this.messages.require(GOTOACK) as GotoAck;
         _loc2_.time_ = param1;
         this.serverConnection.sendMessage(_loc2_);
      }
      
      public function editAccountList(param1:int, param2:Boolean, param3:int) : void
      {
         var _loc4_:EditAccountList = this.messages.require(EDITACCOUNTLIST) as EditAccountList;
         _loc4_.accountListId_ = param1;
         _loc4_.add_ = param2;
         _loc4_.objectId_ = param3;
         this.serverConnection.sendMessage(_loc4_);
      }
      
      public function chooseName(param1:String) : void
      {
         var _loc2_:ChooseName = this.messages.require(CHOOSENAME) as ChooseName;
         _loc2_.name_ = param1;
         this.serverConnection.sendMessage(_loc2_);
      }
      
      public function createGuild(param1:String) : void
      {
         var _loc2_:CreateGuild = this.messages.require(CREATEGUILD) as CreateGuild;
         _loc2_.name_ = param1;
         this.serverConnection.sendMessage(_loc2_);
      }
      
      public function guildRemove(param1:String) : void
      {
         var _loc2_:GuildRemove = this.messages.require(GUILDREMOVE) as GuildRemove;
         _loc2_.name_ = param1;
         this.serverConnection.sendMessage(_loc2_);
      }
      
      public function guildInvite(param1:String) : void
      {
         var _loc2_:GuildInvite = this.messages.require(GUILDINVITE) as GuildInvite;
         _loc2_.name_ = param1;
         this.serverConnection.sendMessage(_loc2_);
      }
      
      public function requestTrade(param1:String) : void
      {
         var _loc2_:RequestTrade = this.messages.require(REQUESTTRADE) as RequestTrade;
         _loc2_.name_ = param1;
         this.serverConnection.sendMessage(_loc2_);
      }
      
      public function changeTrade(param1:Vector.<Boolean>) : void
      {
         var _loc2_:ChangeTrade = this.messages.require(CHANGETRADE) as ChangeTrade;
         _loc2_.offer_ = param1;
         this.serverConnection.sendMessage(_loc2_);
      }
      
      public function partyInvite(param1:String) : void
      {
         var _loc2_:PartyInvite = this.messages.require(PARTY_INVITE) as PartyInvite;
         _loc2_.name_ = param1;
         this.serverConnection.sendMessage(_loc2_);
      }
      
      public function acceptTrade(param1:Vector.<Boolean>, param2:Vector.<Boolean>) : void
      {
         var _loc3_:AcceptTrade = this.messages.require(ACCEPTTRADE) as AcceptTrade;
         _loc3_.myOffer_ = param1;
         _loc3_.yourOffer_ = param2;
         this.serverConnection.sendMessage(_loc3_);
      }
      
      public function acceptFusion(param1:Vector.<ForgeItem>) : void
      {
         var _loc2_:ForgeFusion = this.messages.require(FORGEFUSION) as ForgeFusion;
         _loc2_.myInv = param1;
         this.serverConnection.sendMessage(_loc2_);
      }
      
      public function acceptFuel(param1:Vector.<FuelEngine>) : void
      {
         var _loc2_:FuelEngineAction = this.messages.require(ENGINE_FUEL_ACTION) as FuelEngineAction;
         _loc2_.myInv = param1;
         this.serverConnection.sendMessage(_loc2_);
      }
      
      public function cancelTrade() : void
      {
         this.serverConnection.sendMessage(this.messages.require(CANCELTRADE));
      }
      
      public function escape() : void
      {
         if(this.playerId_ == -1)
         {
            return;
         }
         this.serverConnection.sendMessage(this.messages.require(ESCAPE));
      }
      
      public function joinGuild(param1:String) : void
      {
         var _loc2_:JoinGuild = this.messages.require(JOINGUILD) as JoinGuild;
         _loc2_.guildName_ = param1;
         this.serverConnection.sendMessage(_loc2_);
      }
      
      public function changeGuildRank(param1:String, param2:int) : void
      {
         var _loc3_:ChangeGuildRank = this.messages.require(CHANGEGUILDRANK) as ChangeGuildRank;
         _loc3_.name_ = param1;
         _loc3_.guildRank_ = param2;
         this.serverConnection.sendMessage(_loc3_);
      }
      
      private function onConnected() : void
      {
         var _loc1_:Account = StaticInjectorContext.getInjector().getInstance(Account);
         var _loc2_:Hello = this.messages.require(HELLO) as Hello;
         _loc2_.buildVersion_ = Parameters.FULL_BUILD_VERSION;
         _loc2_.gameId_ = this.gameId_;
         _loc2_.guid_ = rsaEncrypt(_loc1_.getUserId());
         _loc2_.password_ = rsaEncrypt(_loc1_.getPassword());
         _loc2_.keyTime_ = this.keyTime_;
         _loc2_.key_.length = 0;
         this.key_ != null && _loc2_.key_.writeBytes(this.key_);
         _loc2_.mapJSON_ = this.mapJSON_ == null ? "" : this.mapJSON_;
         this.serverConnection.sendMessage(_loc2_);
         this.addTextLine.dispatch(new AddTextLineVO(Parameters.CLIENT_CHAT_NAME,"Connected!"));
      }
      
      private function onCreateSuccess(param1:CreateSuccess) : void
      {
         this.playerId_ = param1.objectId_;
         this.charId_ = param1.charId_;
         this.gs_.initialize();
         this.createCharacter_ = false;
      }
      
      private function onDamage(param1:Damage) : void
      {
         var _loc6_:* = undefined;
         var _loc7_:* = undefined;
         if(!Parameters.data_.allyDamage)
         {
            if(param1.objectId_ != this.playerId_ && param1.targetId_ != this.playerId_)
            {
               return;
            }
         }
         var _loc2_:int = 0;
         var _loc3_:Map = this.gs_.map;
         var _loc4_:Projectile = null;
         if(param1.objectId_ >= 0 && param1.bulletId_ > 0)
         {
            _loc2_ = Projectile.findObjId(param1.objectId_,param1.bulletId_);
            _loc4_ = _loc3_.boDict_[_loc2_] as Projectile;
            if(_loc4_ != null && !_loc4_.projProps_.multiHit_)
            {
               _loc3_.removeObj(_loc2_);
            }
         }
         var _loc5_:GameObject = _loc3_.goDict_[param1.targetId_];
         if(_loc5_ != null)
         {
            _loc5_.damage(-1,param1.damageAmount_,param1.effects_,param1.kill_,_loc4_);
         }
         if(param1.objectId_ != this.playerId_ && param1.targetId_ != this.playerId_)
         {
            return;
         }
         if(param1.objectId_ == this.playerId_)
         {
            if(_loc5_ != null && (_loc5_.props_.isQuest_ || _loc5_.props_.isChest_))
            {
               if(isNaN(Parameters.DamageCounter[param1.targetId_]))
               {
                  Parameters.DamageCounter[param1.targetId_] = 0;
               }
               _loc6_ = param1.targetId_;
               _loc7_ = Parameters.DamageCounter[_loc6_] + param1.damageAmount_;
               Parameters.DamageCounter[_loc6_] = _loc7_;
            }
         }
      }
      
      private function onServerPlayerShoot(param1:ServerPlayerShoot) : void
      {
         var _loc2_:* = param1.ownerId_ == this.playerId_;
         if(!Parameters.data_.allyShots && !_loc2_)
         {
            return;
         }
         var _loc3_:GameObject = this.gs_.map.goDict_[param1.ownerId_];
         if(_loc3_ == null || _loc3_.dead_)
         {
            if(!_loc2_)
            {
            }
            return;
         }
         var _loc4_:Projectile = FreeList.newObject(Projectile) as Projectile;
         _loc4_.reset(param1.containerType_,0,param1.ownerId_,param1.bulletId_,param1.angle_,this.gs_.lastUpdate_);
         _loc4_.setDamage(param1.damage_);
         this.gs_.map.addObj(_loc4_,param1.startingPos_.x_,param1.startingPos_.y_);
         if(!_loc2_)
         {
         }
      }
      
      private function onAllyShoot(param1:AllyShoot) : void
      {
         if(!Parameters.data_.allyShots)
         {
            return;
         }
         var _loc2_:GameObject = this.gs_.map.goDict_[param1.ownerId_];
         if(_loc2_ == null || _loc2_.dead_)
         {
            return;
         }
         var _loc3_:Projectile = FreeList.newObject(Projectile) as Projectile;
         _loc3_.reset(param1.containerType_,0,param1.ownerId_,param1.bulletId_,param1.angle_,this.gs_.lastUpdate_);
         this.gs_.map.addObj(_loc3_,_loc2_.x_,_loc2_.y_);
         _loc2_.setAttack(param1.containerType_,param1.angle_);
      }
      
      private function onEnemyShoot(param1:EnemyShoot) : void
      {
         var _loc2_:Projectile = null;
         var _loc3_:Number = NaN;
         var _loc4_:GameObject = this.gs_.map.goDict_[param1.ownerId_];
         if(_loc4_ == null || _loc4_.dead_)
         {
            return;
         }
         var _loc5_:int = 0;
         while(_loc5_ < param1.numShots_)
         {
            _loc2_ = FreeList.newObject(Projectile) as Projectile;
            _loc3_ = param1.angle_ + param1.angleInc_ * _loc5_;
            _loc2_.reset(_loc4_.objectType_,param1.bulletType_,param1.ownerId_,(param1.bulletId_ + _loc5_) % 256,_loc3_,this.gs_.lastUpdate_);
            _loc2_.setDamage(param1.damage_);
            this.gs_.map.addObj(_loc2_,param1.startingPos_.x_,param1.startingPos_.y_);
            _loc2_.addTo(this.gs_.map,param1.startingPos_.x_,param1.startingPos_.y_);
            _loc5_++;
         }
         _loc4_.setAttack(_loc4_.objectType_,param1.angle_ + param1.angleInc_ * ((param1.numShots_ - 1) / 2));
      }
      
      private function onTradeRequested(param1:TradeRequested) : void
      {
         if(Parameters.data_.showTradePopup)
         {
            this.gs_.hudView.interactPanel.setOverride(new TradeRequestPanel(this.gs_,param1.name_));
         }
         this.addTextLine.dispatch(new AddTextLineVO("",param1.name_ + " wants to " + "trade with you.  Type \"/trade " + param1.name_ + "\" to trade."));
      }
      
      private function onTradeStart(param1:TradeStart) : void
      {
         this.gs_.hudView.startTrade(this.gs_,param1);
      }
      
      private function onTradeChanged(param1:TradeChanged) : void
      {
         this.gs_.hudView.tradeChanged(param1);
      }
      
      private function onTradeDone(param1:TradeDone) : void
      {
         this.gs_.hudView.tradeDone();
         this.addTextLine.dispatch(new AddTextLineVO("",param1.description_));
      }
      
      private function onTradeAccepted(param1:TradeAccepted) : void
      {
         this.gs_.hudView.tradeAccepted(param1);
      }
      
      private function addObject(param1:ObjectData) : void
      {
         var _loc2_:Map = this.gs_.map;
         var _loc3_:GameObject = ObjectLibrary.getObjectFromType(param1.objectType_);
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:ObjectStatusData = param1.status_;
         _loc3_.setObjectId(_loc4_.objectId_);
         _loc2_.addObj(_loc3_,_loc4_.pos_.x_,_loc4_.pos_.y_);
         if(_loc3_ is Player)
         {
            this.handleNewPlayer(_loc3_ as Player,_loc2_);
         }
         this.processObjectStatus(_loc4_,0,-1);
         if(_loc3_.props_.static_ && _loc3_.props_.occupySquare_ && !_loc3_.props_.noMiniMap_)
         {
            this.updateGameObjectTileSignal.dispatch(new UpdateGameObjectTileVO(_loc3_.x_,_loc3_.y_,_loc3_));
         }
      }
      
      private function handleNewPlayer(param1:Player, param2:Map) : void
      {
         this.setPlayerSkinTemplate(param1,0);
         if(param1.objectId_ == this.playerId_)
         {
            this.player = param1;
            this.model.player = param1;
            param2.player_ = param1;
            this.gs_.setFocus(param1);
            this.setGameFocus.dispatch(this.playerId_.toString());
         }
      }
      
      private function onUpdate(param1:Update) : void
      {
         var _loc2_:int = 0;
         var _loc3_:GroundTileData = null;
         var _loc4_:Message = this.messages.require(UPDATEACK);
         this.serverConnection.sendMessage(_loc4_);
         _loc2_ = 0;
         while(_loc2_ < param1.tiles_.length)
         {
            _loc3_ = param1.tiles_[_loc2_];
            this.gs_.map.setGroundTile(_loc3_.x_,_loc3_.y_,_loc3_.type_);
            this.updateGroundTileSignal.dispatch(new UpdateGroundTileVO(_loc3_.x_,_loc3_.y_,_loc3_.type_));
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < param1.drops_.length)
         {
            this.gs_.map.removeObj(param1.drops_[_loc2_]);
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < param1.newObjs_.length)
         {
            this.addObject(param1.newObjs_[_loc2_]);
            _loc2_++;
         }
      }
      
      private function onNotification(param1:Notification) : void
      {
         var _loc2_:CharacterStatusText = null;
         var _loc3_:GameObject = this.gs_.map.goDict_[param1.objectId_];
         if(_loc3_ != null)
         {
            if(this.gs_.map.player_.objectId_ != param1.playerId_ && param1.objectId_ != this.playerId_ && !Parameters.data_.allyNotifs)
            {
               return;
            }
            _loc2_ = new CharacterStatusText(_loc3_,param1.text_,param1.color_,2000);
            this.gs_.map.mapOverlay_.addStatusText(_loc2_);
            if(_loc3_ == this.player && param1.text_ == "Quest Complete!")
            {
               this.gs_.map.quest_.completed();
            }
         }
      }
      
      private function onGlobalNotification(param1:GlobalNotification) : void
      {
         switch(param1.text)
         {
            case "yellow":
               ShowKeySignal.instance.dispatch(Key.YELLOW);
               break;
            case "red":
               ShowKeySignal.instance.dispatch(Key.RED);
               break;
            case "green":
               ShowKeySignal.instance.dispatch(Key.GREEN);
               break;
            case "purple":
               ShowKeySignal.instance.dispatch(Key.PURPLE);
               break;
            case "showKeyUI":
               ShowKeyUISignal.instance.dispatch();
               break;
            case "legloot":
               LegendaryPopUpSignal.instance.dispatch();
               break;
            case "revloot":
               RevengePopUpSignal.instance.dispatch();
               break;
            case "monkeyKing":
               RevengePopUpSignal.instance.dispatch();
               break;
            case "eternalloot":
               EternalPopUpSignal.instance.dispatch();
         }
      }
      
      private function onNewTick(param1:NewTick) : void
      {
         var _loc2_:ObjectStatusData = null;
         if(this.jitterWatcher_ != null)
         {
            this.jitterWatcher_.record();
         }
         this.move(param1.tickId_,this.player);
         for each(_loc2_ in param1.statuses_)
         {
            this.processObjectStatus(_loc2_,param1.tickTime_,param1.tickId_);
         }
         this.lastTickId_ = param1.tickId_;
      }
      
      private function canShowEffect(param1:GameObject) : Boolean
      {
         var _loc2_:* = param1.objectId_ == this.playerId_;
         return !_loc2_ && param1 is Player && Parameters.data_.disableAllyParticles;
      }
      
      private function onShowEffect(param1:ShowEffect) : void
      {
         var _loc2_:GameObject = null;
         var _loc3_:ParticleEffect = null;
         var _loc4_:Point = null;
         var _loc5_:Map = this.gs_.map;
         switch(param1.effectType_)
         {
            case ShowEffect.HEAL_EFFECT_TYPE:
               _loc2_ = _loc5_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null || !this.canShowEffect(_loc2_))
               {
                  break;
               }
               _loc5_.addObj(new HealEffect(_loc2_,param1.color_),_loc2_.x_,_loc2_.y_);
               break;
            case ShowEffect.TELEPORT_EFFECT_TYPE:
               if(param1.targetObjectId_ != this.playerId_ && Parameters.data_.disableAllParticles)
               {
                  return;
               }
               _loc5_.addObj(new TeleportEffect(),param1.pos1_.x_,param1.pos1_.y_);
               break;
            case ShowEffect.STREAM_EFFECT_TYPE:
               if(param1.targetObjectId_ != this.playerId_ && Parameters.data_.disableAllParticles)
               {
                  return;
               }
               _loc3_ = new StreamEffect(param1.pos1_,param1.pos2_,param1.color_);
               _loc5_.addObj(_loc3_,param1.pos1_.x_,param1.pos1_.y_);
               break;
            case ShowEffect.THROW_EFFECT_TYPE:
               _loc2_ = _loc5_.goDict_[param1.targetObjectId_];
               _loc4_ = _loc2_ != null ? new Point(_loc2_.x_,_loc2_.y_) : param1.pos2_.toPoint();
               _loc3_ = new ThrowEffect(_loc4_,param1.pos1_.toPoint(),param1.color_,param1.duration_ * 1000);
               _loc5_.addObj(_loc3_,_loc4_.x,_loc4_.y);
               break;
            case ShowEffect.NOVA_EFFECT_TYPE:
               if(param1.pos2_.y_ == 255 && param1.pos2_.x_ != this.playerId_ && Parameters.data_.disableAllParticles)
               {
                  return;
               }
               _loc2_ = _loc5_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null || param1.pos2_.y_ == 255 && param1.pos2_.x_ != this.playerId_ && (Parameters.data_.disableAllyParticles || Parameters.data_.disableAllParticles))
               {
                  break;
               }
               _loc3_ = new NovaEffect(_loc2_,param1.pos1_.x_,param1.color_);
               _loc5_.addObj(_loc3_,_loc2_.x_,_loc2_.y_);
               break;
            case ShowEffect.POISON_EFFECT_TYPE:
               if(param1.targetObjectId_ != this.playerId_ && Parameters.data_.disableAllParticles)
               {
                  return;
               }
               _loc2_ = _loc5_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null)
               {
                  break;
               }
               _loc3_ = new PoisonEffect(_loc2_,param1.color_);
               _loc5_.addObj(_loc3_,_loc2_.x_,_loc2_.y_);
               break;
            case ShowEffect.LINE_EFFECT_TYPE:
               _loc2_ = _loc5_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null)
               {
                  break;
               }
               if(param1.targetObjectId_ != this.playerId_ && Parameters.data_.disableAllParticles)
               {
                  return;
               }
               _loc3_ = new LineEffect(_loc2_,param1.pos1_,param1.color_);
               _loc5_.addObj(_loc3_,param1.pos1_.x_,param1.pos1_.y_);
               break;
            case ShowEffect.BURST_EFFECT_TYPE:
               if(param1.targetObjectId_ != this.playerId_ && Parameters.data_.disableAllParticles)
               {
                  return;
               }
               _loc2_ = _loc5_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null)
               {
                  break;
               }
               _loc3_ = new BurstEffect(_loc2_,param1.pos1_,param1.pos2_,param1.color_);
               _loc5_.addObj(_loc3_,param1.pos1_.x_,param1.pos1_.y_);
               break;
            case ShowEffect.FLOW_EFFECT_TYPE:
               if(param1.targetObjectId_ != this.playerId_ && Parameters.data_.disableAllParticles)
               {
                  return;
               }
               _loc2_ = _loc5_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null)
               {
                  break;
               }
               _loc3_ = new FlowEffect(param1.pos1_,_loc2_,param1.color_);
               _loc5_.addObj(_loc3_,param1.pos1_.x_,param1.pos1_.y_);
               break;
            case ShowEffect.RING_EFFECT_TYPE:
               if(param1.targetObjectId_ != this.playerId_ && Parameters.data_.disableAllParticles)
               {
                  return;
               }
               _loc2_ = _loc5_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null)
               {
                  break;
               }
               _loc3_ = new RingEffect(_loc2_,param1.pos1_.x_,param1.color_);
               _loc5_.addObj(_loc3_,_loc2_.x_,_loc2_.y_);
               break;
            case ShowEffect.LIGHTNING_EFFECT_TYPE:
               _loc2_ = _loc5_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null)
               {
                  break;
               }
               _loc3_ = new LightningEffect(_loc2_,param1.pos1_,param1.color_,param1.pos2_.x_);
               _loc5_.addObj(_loc3_,_loc2_.x_,_loc2_.y_);
               break;
            case ShowEffect.COLLAPSE_EFFECT_TYPE:
               if(param1.targetObjectId_ != this.playerId_ && Parameters.data_.disableAllParticles)
               {
                  return;
               }
               _loc2_ = _loc5_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null)
               {
                  break;
               }
               _loc3_ = new CollapseEffect(_loc2_,param1.pos1_,param1.pos2_,param1.color_);
               _loc5_.addObj(_loc3_,param1.pos1_.x_,param1.pos1_.y_);
               break;
            case ShowEffect.CONEBLAST_EFFECT_TYPE:
               if(param1.targetObjectId_ != this.playerId_ && Parameters.data_.disableAllParticles)
               {
                  return;
               }
               _loc2_ = _loc5_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null)
               {
                  break;
               }
               _loc3_ = new ConeBlastEffect(_loc2_,param1.pos1_,param1.pos2_.x_,param1.color_);
               _loc5_.addObj(_loc3_,_loc2_.x_,_loc2_.y_);
               break;
            case ShowEffect.JITTER_EFFECT_TYPE:
               if(param1.targetObjectId_ != this.playerId_ && Parameters.data_.disableAllParticles)
               {
                  return;
               }
               this.gs_.camera_.startJitter();
               break;
            case ShowEffect.FLASH_EFFECT_TYPE:
               if(param1.targetObjectId_ != this.playerId_ && Parameters.data_.disableAllParticles)
               {
                  return;
               }
               _loc2_ = _loc5_.goDict_[param1.targetObjectId_];
               if(_loc2_ == null)
               {
                  break;
               }
               _loc2_.flash_ = new FlashDescription(getTimer(),param1.color_,param1.pos1_.x_,param1.pos1_.y_);
               break;
            case ShowEffect.THROW_PROJECTILE_EFFECT_TYPE:
               _loc2_ = _loc5_.goDict_[param1.targetObjectId_];
               _loc4_ = _loc4_ != null ? new Point(_loc2_.x_,_loc2_.y_) : param1.pos2_.toPoint();
               _loc3_ = new ThrowProjectileEffect(param1.objectType,param1.pos1_.toPoint(),_loc4_,param1.duration_ * 1000);
               _loc5_.addObj(_loc3_,_loc4_.x,_loc4_.y);
         }
      }
      
      private function onGoto(param1:Goto) : void
      {
         this.gotoAck(this.gs_.lastUpdate_);
         var _loc2_:GameObject = this.gs_.map.goDict_[param1.objectId_];
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.onGoto(param1.pos_.x_,param1.pos_.y_,this.gs_.lastUpdate_);
      }
      
      private function updateGameObject(param1:GameObject, param2:Vector.<StatData>, param3:Boolean) : void
      {
         var _loc4_:StatData = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Player = param1 as Player;
         var _loc8_:Merchant = param1 as Merchant;
         for each(_loc4_ in param2)
         {
            _loc5_ = _loc4_.statValue_;
            switch(_loc4_.statType_)
            {
               case StatData.MAX_HP_STAT:
                  param1.maxHP_ = _loc5_;
                  break;
               case StatData.HP_STAT:
                  param1.hp_ = _loc5_;
                  break;
               case StatData.SIZE_STAT:
                  param1.size_ = _loc5_;
                  break;
               case StatData.MAX_MP_STAT:
                  _loc7_.maxMP_ = _loc5_;
                  break;
               case StatData.MP_STAT:
                  _loc7_.mp_ = _loc5_;
                  break;
               case StatData.NEXT_LEVEL_EXP_STAT:
                  _loc7_.nextLevelExp_ = _loc5_;
                  break;
               case StatData.EXP_STAT:
                  _loc7_.exp_ = _loc5_;
                  break;
               case StatData.LEVEL_STAT:
                  param1.level_ = _loc5_;
                  break;
               case StatData.ATTACK_STAT:
                  _loc7_.attack_ = _loc5_;
                  break;
               case StatData.DEFENSE_STAT:
                  param1.defense_ = _loc5_;
                  break;
               case StatData.SPEED_STAT:
                  _loc7_.speed_ = _loc5_;
                  break;
               case StatData.DEXTERITY_STAT:
                  _loc7_.dexterity_ = _loc5_;
                  break;
               case StatData.VITALITY_STAT:
                  _loc7_.vitality_ = _loc5_;
                  break;
               case StatData.WISDOM_STAT:
                  _loc7_.wisdom_ = _loc5_;
                  break;
               case StatData.CONDITION_STAT:
                  param1.condition_[0] = _loc5_;
                  break;
               case StatData.INVENTORY_0_STAT:
               case StatData.INVENTORY_1_STAT:
               case StatData.INVENTORY_2_STAT:
               case StatData.INVENTORY_3_STAT:
               case StatData.INVENTORY_4_STAT:
               case StatData.INVENTORY_5_STAT:
               case StatData.INVENTORY_6_STAT:
               case StatData.INVENTORY_7_STAT:
               case StatData.INVENTORY_8_STAT:
               case StatData.INVENTORY_9_STAT:
               case StatData.INVENTORY_10_STAT:
               case StatData.INVENTORY_11_STAT:
                  param1.equipment_[_loc4_.statType_ - StatData.INVENTORY_0_STAT] = _loc5_;
                  break;
               case StatData.NUM_STARS_STAT:
                  _loc7_.numStars_ = _loc5_;
                  break;
               case StatData.NAME_STAT:
                  if(param1.name_ != _loc4_.strStatValue_)
                  {
                     param1.name_ = _loc4_.strStatValue_;
                     param1.nameBitmapData_ = null;
                  }
                  break;
               case StatData.TEX1_STAT:
                  param1.setTex1(_loc5_);
                  break;
               case StatData.TEX2_STAT:
                  param1.setTex2(_loc5_);
                  break;
               case StatData.MERCHANDISE_TYPE_STAT:
                  if(_loc8_ != null)
                  {
                     _loc8_.setMerchandiseType(_loc5_);
                  }
                  break;
               case StatData.CREDITS_STAT:
                  _loc7_.setCredits(_loc5_);
                  break;
               case StatData.MERCHANDISE_PRICE_STAT:
                  if(param1 is SellableObject)
                  {
                     (param1 as SellableObject).setPrice(_loc5_);
                  }
                  break;
               case StatData.ACTIVE_STAT:
                  (param1 as Portal).active_ = _loc5_ != 0;
                  break;
               case StatData.ACCOUNT_ID_STAT:
                  _loc7_.accountId_ = _loc5_;
                  break;
               case StatData.FAME_STAT:
                  _loc7_.fame_ = _loc5_;
                  break;
               case StatData.MERCHANDISE_CURRENCY_STAT:
                  if(param1 is SellableObject)
                  {
                     (param1 as SellableObject).setCurrency(_loc5_);
                  }
                  break;
               case StatData.CONNECT_STAT:
                  param1.connectType_ = _loc5_;
                  break;
               case StatData.MERCHANDISE_COUNT_STAT:
                  if(_loc8_ != null)
                  {
                     _loc8_.count_ = _loc5_;
                     _loc8_.untilNextMessage_ = 0;
                  }
                  break;
               case StatData.MERCHANDISE_MINS_LEFT_STAT:
                  if(_loc8_ != null)
                  {
                     _loc8_.minsLeft_ = _loc5_;
                     _loc8_.untilNextMessage_ = 0;
                  }
                  break;
               case StatData.MERCHANDISE_DISCOUNT_STAT:
                  if(_loc8_ != null)
                  {
                     _loc8_.discount_ = _loc5_;
                     _loc8_.untilNextMessage_ = 0;
                  }
                  break;
               case StatData.MERCHANDISE_RANK_REQ_STAT:
                  if(param1 is SellableObject)
                  {
                     (param1 as SellableObject).setRankReq(_loc5_);
                  }
                  break;
               case StatData.MAX_HP_BOOST_STAT:
                  _loc7_.maxHPBoost_ = _loc5_;
                  break;
               case StatData.MAX_MP_BOOST_STAT:
                  _loc7_.maxMPBoost_ = _loc5_;
                  break;
               case StatData.ATTACK_BOOST_STAT:
                  _loc7_.attackBoost_ = _loc5_;
                  break;
               case StatData.DEFENSE_BOOST_STAT:
                  _loc7_.defenseBoost_ = _loc5_;
                  break;
               case StatData.SPEED_BOOST_STAT:
                  _loc7_.speedBoost_ = _loc5_;
                  break;
               case StatData.VITALITY_BOOST_STAT:
                  _loc7_.vitalityBoost_ = _loc5_;
                  break;
               case StatData.WISDOM_BOOST_STAT:
                  _loc7_.wisdomBoost_ = _loc5_;
                  break;
               case StatData.DEXTERITY_BOOST_STAT:
                  _loc7_.dexterityBoost_ = _loc5_;
                  break;
               case StatData.OWNER_ACCOUNT_ID_STAT:
                  (param1 as Container).setOwnerId(_loc5_);
                  break;
               case StatData.RANK_REQUIRED_STAT:
                  (param1 as NameChanger).setRankRequired(_loc5_);
                  break;
               case StatData.NAME_CHOSEN_STAT:
                  _loc7_.nameChosen_ = _loc5_ != 0;
                  param1.nameBitmapData_ = null;
                  break;
               case StatData.CURR_FAME_STAT:
                  _loc7_.currFame_ = _loc5_;
                  break;
               case StatData.NEXT_CLASS_QUEST_FAME_STAT:
                  _loc7_.nextClassQuestFame_ = _loc5_;
                  break;
               case StatData.GLOW_COLOR:
                  param1.setGlow(_loc5_);
                  break;
               case StatData.SINK_LEVEL_STAT:
                  if(!param3)
                  {
                     _loc7_.sinkLevel_ = _loc5_;
                  }
                  break;
               case StatData.ALT_TEXTURE_STAT:
                  param1.setAltTexture(_loc5_);
                  break;
               case StatData.GUILD_NAME_STAT:
                  _loc7_.setGuildName(_loc4_.strStatValue_);
                  break;
               case StatData.GUILD_RANK_STAT:
                  _loc7_.guildRank_ = _loc5_;
                  break;
               case StatData.BREATH_STAT:
                  _loc7_.breath_ = _loc5_;
                  break;
               case StatData.HEALTH_POTION_STACK_STAT:
                  _loc7_.healthPotionCount_ = _loc5_;
                  break;
               case StatData.MAGIC_POTION_STACK_STAT:
                  _loc7_.magicPotionCount_ = _loc5_;
                  break;
               case StatData.TEXTURE_STAT:
                  _loc7_.skinId != _loc5_ && this.setPlayerSkinTemplate(_loc7_,_loc5_);
                  break;
               case StatData.LD_TIMER_STAT:
                  _loc7_.dropBoost = _loc5_ * 1000;
                  break;
               case StatData.HASBACKPACK_STAT:
                  (param1 as Player).hasBackpack_ = Boolean(_loc5_);
                  if(param3)
                  {
                     this.updateBackpackTab.dispatch(Boolean(_loc5_));
                  }
                  break;
               case StatData.BACKPACK_0_STAT:
               case StatData.BACKPACK_1_STAT:
               case StatData.BACKPACK_2_STAT:
               case StatData.BACKPACK_3_STAT:
               case StatData.BACKPACK_4_STAT:
               case StatData.BACKPACK_5_STAT:
               case StatData.BACKPACK_6_STAT:
               case StatData.BACKPACK_7_STAT:
                  _loc6_ = _loc4_.statType_ - StatData.BACKPACK_0_STAT + GeneralConstants.NUM_EQUIPMENT_SLOTS + GeneralConstants.NUM_INVENTORY_SLOTS;
                  (param1 as Player).equipment_[_loc6_] = _loc5_;
                  break;
               case StatData.SPS_LIFE_COUNT:
                  _loc7_.SPS_Life = _loc5_;
                  if(_loc7_.SPS_Modal != null)
                  {
                     _loc7_.SPS_Modal.draw();
                  }
                  break;
               case StatData.SPS_LIFE_COUNT_MAX:
                  _loc7_.SPS_Life_Max = _loc5_;
                  if(_loc7_.SPS_Modal != null)
                  {
                     _loc7_.SPS_Modal.draw();
                  }
                  break;
               case StatData.SPS_MANA_COUNT:
                  _loc7_.SPS_Mana = _loc5_;
                  if(_loc7_.SPS_Modal != null)
                  {
                     _loc7_.SPS_Modal.draw();
                  }
                  break;
               case StatData.SPS_MANA_COUNT_MAX:
                  _loc7_.SPS_Mana_Max = _loc5_;
                  if(_loc7_.SPS_Modal != null)
                  {
                     _loc7_.SPS_Modal.draw();
                  }
                  break;
               case StatData.SPS_DEFENSE_COUNT:
                  _loc7_.SPS_Defense = _loc5_;
                  if(_loc7_.SPS_Modal != null)
                  {
                     _loc7_.SPS_Modal.draw();
                  }
                  break;
               case StatData.SPS_DEFENSE_COUNT_MAX:
                  _loc7_.SPS_Defense_Max = _loc5_;
                  if(_loc7_.SPS_Modal != null)
                  {
                     _loc7_.SPS_Modal.draw();
                  }
                  break;
               case StatData.SPS_ATTACK_COUNT:
                  _loc7_.SPS_Attack = _loc5_;
                  if(_loc7_.SPS_Modal != null)
                  {
                     _loc7_.SPS_Modal.draw();
                  }
                  break;
               case StatData.SPS_ATTACK_COUNT_MAX:
                  _loc7_.SPS_Attack_Max = _loc5_;
                  if(_loc7_.SPS_Modal != null)
                  {
                     _loc7_.SPS_Modal.draw();
                  }
                  break;
               case StatData.SPS_DEXTERITY_COUNT:
                  _loc7_.SPS_Dexterity = _loc5_;
                  if(_loc7_.SPS_Modal != null)
                  {
                     _loc7_.SPS_Modal.draw();
                  }
                  break;
               case StatData.SPS_DEXTERITY_COUNT_MAX:
                  _loc7_.SPS_Dexterity_Max = _loc5_;
                  if(_loc7_.SPS_Modal != null)
                  {
                     _loc7_.SPS_Modal.draw();
                  }
                  break;
               case StatData.SPS_SPEED_COUNT:
                  _loc7_.SPS_Speed = _loc5_;
                  if(_loc7_.SPS_Modal != null)
                  {
                     _loc7_.SPS_Modal.draw();
                  }
                  break;
               case StatData.SPS_SPEED_COUNT_MAX:
                  _loc7_.SPS_Speed_Max = _loc5_;
                  if(_loc7_.SPS_Modal != null)
                  {
                     _loc7_.SPS_Modal.draw();
                  }
                  break;
               case StatData.SPS_VITALITY_COUNT:
                  _loc7_.SPS_Vitality = _loc5_;
                  if(_loc7_.SPS_Modal != null)
                  {
                     _loc7_.SPS_Modal.draw();
                  }
                  break;
               case StatData.SPS_VITALITY_COUNT_MAX:
                  _loc7_.SPS_Vitality_Max = _loc5_;
                  if(_loc7_.SPS_Modal != null)
                  {
                     _loc7_.SPS_Modal.draw();
                  }
                  break;
               case StatData.SPS_WISDOM_COUNT:
                  _loc7_.SPS_Wisdom = _loc5_;
                  if(_loc7_.SPS_Modal != null)
                  {
                     _loc7_.SPS_Modal.draw();
                  }
                  break;
               case StatData.SPS_WISDOM_COUNT_MAX:
                  _loc7_.SPS_Wisdom_Max = _loc5_;
                  if(_loc7_.SPS_Modal != null)
                  {
                     _loc7_.SPS_Modal.draw();
                  }
                  break;
               case StatData.ENGINE_VALUE:
                  (param1 as Engine).currentValue_ = _loc5_;
                  break;
               case StatData.ENGINE_TIME:
                  (param1 as Engine).engineTime_ = _loc5_;
                  break;
               case StatData.BASESTAT:
                  _loc7_.baseStat = _loc5_;
                  break;
               case StatData.POINTS:
                  _loc7_.points = _loc5_;
                  break;
               case StatData.GLOW_ENEMY_COLOR:
                  param1.setGlowEnemy(_loc5_);
                  break;
               case StatData.XP_BOOSTED:
                  _loc7_.xpBoost_ = _loc5_;
                  break;
               case StatData.XP_TIMER_BOOST:
                  _loc7_.xpTimer = _loc5_ * TO_MILLISECONDS;
                  break;
               case StatData.RANK:
                  _loc7_.rank = _loc5_;
                  break;
               case StatData.CHAT_COLOR:
                  _loc7_.chatColor = _loc5_;
                  break;
               case StatData.NAME_CHAT_COLOR:
                  _loc7_.nameChatColor = _loc5_;
                  break;
               case StatData.UPGRADEENABLED:
                  _loc7_.upgraded_ = _loc5_ == 1;
                  break;
               case StatData.CONDITION_STAT_2:
                  param1.condition_[1] = _loc5_;
                  break;
               case StatData.PARTYID:
                  _loc7_.partyId_ = _loc5_;
                  _loc7_.setParty();
                  break;
               case StatData.INVDATA0:
               case StatData.INVDATA1:
               case StatData.INVDATA2:
               case StatData.INVDATA3:
               case StatData.INVDATA4:
               case StatData.INVDATA5:
               case StatData.INVDATA6:
               case StatData.INVDATA7:
               case StatData.INVDATA8:
               case StatData.INVDATA9:
               case StatData.INVDATA10:
               case StatData.INVDATA11:
                  param1.equipData_[_loc4_.statType_ - StatData.INVDATA0] = JSON.parse(_loc4_.strStatValue_);
                  break;
               case StatData.BACKPACKDATA0:
               case StatData.BACKPACKDATA1:
               case StatData.BACKPACKDATA2:
               case StatData.BACKPACKDATA3:
               case StatData.BACKPACKDATA4:
               case StatData.BACKPACKDATA5:
               case StatData.BACKPACKDATA6:
               case StatData.BACKPACKDATA7:
                  _loc6_ = _loc4_.statType_ - StatData.BACKPACKDATA0 + GeneralConstants.NUM_EQUIPMENT_SLOTS + GeneralConstants.NUM_INVENTORY_SLOTS;
                  (param1 as Player).equipData_[_loc6_] = JSON.parse(_loc4_.strStatValue_);
                  break;
               case StatData.NO_MANA_BAR:
                  (param1 as Player).talismanNoManaBar_ = _loc4_.statValue_ == 1;
                  this.gs_.hudView.draw();
                  break;
            }
         }
      }
      
      private function setPlayerSkinTemplate(param1:Player, param2:int) : void
      {
         var _loc3_:Reskin = this.messages.require(RESKIN) as Reskin;
         _loc3_.skinID = param2;
         _loc3_.player = param1;
         _loc3_.consume();
      }
      
      private function get requireInterpolation() : Boolean
      {
         return this.jitterWatcher_ && this.jitterWatcher_.getNetJitter > Parameters.INTERPOLATION_THRESHOLD;
      }
      
      private function processObjectStatus(param1:ObjectStatusData, param2:int, param3:int) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Array = null;
         var _loc8_:CharacterClass = null;
         var _loc9_:Map = this.gs_.map;
         var _loc10_:GameObject = _loc9_.goDict_[param1.objectId_];
         if(_loc10_ == null)
         {
            return;
         }
         var _loc11_:* = param1.objectId_ == this.playerId_;
         var _loc12_:Boolean = Parameters.data_.allyNotifs;
         if(param2 != 0 && !_loc11_)
         {
            _loc10_.onTickPos(param1.pos_.x_,param1.pos_.y_,param2,param3,this.requireInterpolation);
         }
         var _loc13_:Player = _loc10_ as Player;
         if(_loc13_ != null)
         {
            _loc4_ = _loc13_.level_;
            _loc5_ = _loc13_.exp_;
            _loc6_ = _loc13_.fame_;
         }
         this.updateGameObject(_loc10_,param1.stats_,_loc11_);
         if(_loc13_ != null && _loc4_ != -1)
         {
            if(_loc13_.level_ > _loc4_)
            {
               if(_loc11_)
               {
                  _loc7_ = this.gs_.model.getNewUnlocks(_loc13_.objectType_,_loc13_.level_);
                  _loc13_.handleLevelUp(_loc7_.length != 0);
                  _loc8_ = this.classesModel.getCharacterClass(_loc13_.objectType_);
                  if(_loc8_.getMaxLevelAchieved() < _loc13_.level_)
                  {
                     _loc8_.setMaxLevelAchieved(_loc13_.level_);
                  }
               }
               else if(_loc12_)
               {
                  _loc13_.levelUpEffect("Level Up!");
               }
            }
            else if(_loc13_.exp_ > _loc5_)
            {
               if(!_loc12_ && !_loc11_)
               {
                  return;
               }
               _loc13_.handleExpUp(_loc13_.exp_ - _loc5_);
               _loc13_.handleFameUp(_loc13_.fame_ - _loc6_);
            }
         }
      }
      
      private function onText(param1:Text) : void
      {
         var _loc2_:GameObject = null;
         var _loc3_:Vector.<uint> = null;
         var _loc4_:AddSpeechBalloonVO = null;
         var _loc5_:String = param1.text_;
         if(param1.objectId_ >= 0)
         {
            _loc2_ = this.gs_.map.goDict_[param1.objectId_];
            if(_loc2_ != null)
            {
               _loc3_ = NORMAL_SPEECH_COLORS;
               if(_loc2_.props_.isEnemy_)
               {
                  _loc3_ = ENEMY_SPEECH_COLORS;
               }
               else if(param1.recipient_ == Parameters.GUILD_CHAT_NAME)
               {
                  _loc3_ = GUILD_SPEECH_COLORS;
               }
               else if(param1.recipient_ == Parameters.PARTY_CHAT_NAME)
               {
                  _loc3_ = PARTY_SPEECH_COLORS;
               }
               else if(param1.recipient_ != "")
               {
                  _loc3_ = TELL_SPEECH_COLORS;
               }
               _loc4_ = new AddSpeechBalloonVO(_loc2_,_loc5_,"",false,false,_loc3_[0],1,_loc3_[1],1,_loc3_[2],param1.bubbleTime_,false,true);
               this.addSpeechBalloon.dispatch(_loc4_);
            }
         }
         this.addTextLine.dispatch(new AddTextLineVO(param1.name_,_loc5_,param1.objectId_,param1.numStars_,param1.recipient_,param1.nameColor_,param1.textColor_));
      }
      
      private function onInvResult(param1:InvResult) : void
      {
         if(param1.result_ != 0)
         {
            this.handleInvFailure();
         }
      }
      
      private function handleInvFailure() : void
      {
         SoundEffectLibrary.play("error");
         this.gs_.hudView.interactPanel.redraw();
      }
      
      private function onReconnect(param1:Reconnect) : void
      {
         this.disconnect();
         var _loc2_:Server = new Server().setName(param1.name_).setAddress(param1.host_ != "" ? param1.host_ : this.server_.address).setPort(param1.host_ != "" ? int(int(param1.port_)) : int(int(this.server_.port)));
         var _loc3_:int = param1.gameId_;
         var _loc4_:Boolean = this.createCharacter_;
         var _loc5_:int = this.charId_;
         var _loc6_:int = param1.keyTime_;
         var _loc7_:ByteArray = param1.key_;
         var _loc8_:ReconnectEvent = new ReconnectEvent(_loc2_,_loc3_,_loc4_,_loc5_,_loc6_,_loc7_);
         this.gs_.dispatchEvent(_loc8_);
      }
      
      private function onPing(param1:Ping) : void
      {
         var _loc2_:Pong = this.messages.require(PONG) as Pong;
         _loc2_.serial_ = param1.serial_;
         _loc2_.time_ = getTimer();
         this.serverConnection.sendMessage(_loc2_);
      }
      
      private function onMapInfo(param1:MapInfo) : void
      {
         this.gs_.applyMapInfo(param1);
         this.rand_ = new Random(param1.fp_);
         Music.load(param1.music);
         if(this.createCharacter_)
         {
            this.create();
         }
         else
         {
            this.load();
         }
      }
      
      private function onPic(param1:Pic) : void
      {
         this.gs_.addChild(new PicView(param1.bitmapData_));
      }
      
      private function onDeath(param1:Death) : void
      {
         this.disconnect();
         this.death = param1;
         var _loc2_:BitmapData = new BitmapData(this.gs_.stage.stageWidth,this.gs_.stage.stageHeight);
         _loc2_.draw(this.gs_);
         param1.background = _loc2_;
         if(!this.gs_.isEditor)
         {
            this.handleDeath.dispatch(param1);
         }
      }
      
      private function onBuyResult(param1:BuyResult) : void
      {
         if(param1.result_ == BuyResult.SUCCESS_BRID)
         {
            if(!this.outstandingBuy_)
            {
            }
         }
         this.outstandingBuy_ = null;
         switch(param1.result_)
         {
            case BuyResult.DIALOG_BRID:
               StaticInjectorContext.getInjector().getInstance(OpenDialogSignal).dispatch(new FlexibleDialog("Purchase Error",param1.resultString_));
               break;
            default:
               this.addTextLine.dispatch(new AddTextLineVO(param1.result_ == BuyResult.SUCCESS_BRID ? Parameters.SERVER_CHAT_NAME : Parameters.ERROR_CHAT_NAME,param1.resultString_));
         }
      }
      
      private function onAccountList(param1:AccountList) : void
      {
         if(param1.accountListId_ == 0)
         {
            this.gs_.map.party_.setStars(param1);
         }
         if(param1.accountListId_ == 1)
         {
            this.gs_.map.party_.setIgnores(param1);
         }
      }
      
      private function onQuestObjId(param1:QuestObjId) : void
      {
         this.gs_.map.quest_.setObject(param1.objectId_);
      }
      
      private function onAoe(param1:Aoe) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Vector.<uint> = null;
         if(this.player == null)
         {
            return;
         }
         var _loc4_:AOEEffect = new AOEEffect(param1.pos_.toPoint(),param1.radius_,16711680);
         this.gs_.map.addObj(_loc4_,param1.pos_.x_,param1.pos_.y_);
         if(this.player.isInvincible() || this.player.isPaused())
         {
            return;
         }
         var _loc5_:* = this.player.distTo(param1.pos_) < param1.radius_;
         if(_loc5_)
         {
            _loc2_ = GameObject.damageWithDefense(param1.damage_,this.player.defense_,false,this.player.condition_[0]);
            _loc3_ = null;
            if(param1.effect_ != 0)
            {
               _loc3_ = new Vector.<uint>();
               _loc3_.push(param1.effect_);
            }
            this.player.damage(param1.origType_,_loc2_,_loc3_,false,null);
         }
      }
      
      private function onNameResult(param1:NameResult) : void
      {
         this.gs_.dispatchEvent(new NameResultEvent(param1));
      }
      
      private function onGuildResult(param1:GuildResult) : void
      {
         this.addTextLine.dispatch(new AddTextLineVO(Parameters.ERROR_CHAT_NAME,param1.errorText_));
         this.gs_.dispatchEvent(new GuildResultEvent(param1.success_,param1.errorText_));
      }
      
      private function onClientStat(param1:ClientStat) : void
      {
         var _loc2_:Account = StaticInjectorContext.getInjector().getInstance(Account);
         _loc2_.reportIntStat(param1.name_,param1.value_);
      }
      
      private function onFile(param1:File) : void
      {
         new FileReference().save(param1.file_,param1.filename_);
      }
      
      private function onInvitedToGuild(param1:InvitedToGuild) : void
      {
         if(Parameters.data_.showGuildInvitePopup)
         {
            this.gs_.hudView.interactPanel.setOverride(new GuildInvitePanel(this.gs_,param1.name_,param1.guildName_));
         }
         this.addTextLine.dispatch(new AddTextLineVO("","You have been invited by " + param1.name_ + " to join the guild " + param1.guildName_ + ".\n  If you wish to join type \"/join " + param1.guildName_ + "\""));
      }
      
      private function onPlaySound(param1:PlaySound) : void
      {
         var _loc2_:GameObject = this.gs_.map.goDict_[param1.ownerId_];
         _loc2_ && _loc2_.playSound(param1.soundId_);
      }
      
      private function onClosed() : void
      {
         var _loc1_:HideMapLoadingSignal = null;
         if(this.playerId_ != -1)
         {
            this.gs_.closed.dispatch();
         }
         else if(this.retryConnection_)
         {
            if(this.delayBeforeReconect < 12)
            {
               if(this.delayBeforeReconect == 5)
               {
                  _loc1_ = StaticInjectorContext.getInjector().getInstance(HideMapLoadingSignal);
                  _loc1_ && _loc1_.dispatch();
               }
               this.retry();
               ++this.delayBeforeReconect;
               this.addTextLine.dispatch(new AddTextLineVO(Parameters.ERROR_CHAT_NAME,"Connection failed!  Retrying..."));
            }
            else
            {
               this.gs_.closed.dispatch();
            }
         }
      }
      
      private function retry() : void
      {
         this.retryTimer_ = new Timer(1200,1);
         this.retryTimer_.addEventListener(TimerEvent.TIMER_COMPLETE,this.onRetryTimer);
         this.retryTimer_.start();
      }
      
      private function onRetryTimer(param1:TimerEvent) : void
      {
         this.serverConnection.connect(this.server_.address,this.server_.port);
      }
      
      private function onError(param1:String) : void
      {
         this.addTextLine.dispatch(new AddTextLineVO(Parameters.ERROR_CHAT_NAME,param1));
      }
      
      private function onFailure(param1:Failure) : void
      {
         switch(param1.errorId_)
         {
            case Failure.INCORRECT_VERSION:
               this.handleIncorrectVersionFailure(param1);
               break;
            case Failure.FORCE_CLOSE_GAME:
               this.handleForceCloseGameFailure(param1);
               break;
            case Failure.INVALID_TELEPORT_TARGET:
               this.handleInvalidTeleportTarget(param1);
               break;
            default:
               this.handleDefaultFailure(param1);
         }
      }
      
      private function handleInvalidTeleportTarget(param1:Failure) : void
      {
         this.addTextLine.dispatch(new AddTextLineVO(Parameters.ERROR_CHAT_NAME,param1.errorDescription_));
         this.player.nextTeleportAt_ = 0;
      }
      
      private function handleForceCloseGameFailure(param1:Failure) : void
      {
         this.addTextLine.dispatch(new AddTextLineVO(Parameters.ERROR_CHAT_NAME,param1.errorDescription_));
         this.retryConnection_ = false;
         this.gs_.closed.dispatch();
      }
      
      private function handleIncorrectVersionFailure(param1:Failure) : void
      {
         var _loc2_:Dialog = new Dialog("Client version: " + Parameters.BUILD_VERSION + "\nServer version: " + param1.errorDescription_,"Client Update Needed","Ok",null);
         _loc2_.addEventListener(Dialog.BUTTON1_EVENT,this.onDoClientUpdate);
         this.gs_.stage.addChild(_loc2_);
         this.retryConnection_ = false;
      }
      
      private function handleDefaultFailure(param1:Failure) : void
      {
         this.addTextLine.dispatch(new AddTextLineVO(Parameters.ERROR_CHAT_NAME,param1.errorDescription_));
      }
      
      private function onDoClientUpdate(param1:Event) : void
      {
         var _loc2_:Dialog = param1.currentTarget as Dialog;
         _loc2_.parent.removeChild(_loc2_);
         this.gs_.closed.dispatch();
      }
      
      private function onMarketSearchResult(param1:MarketSearchResult) : void
      {
         MemMarketSearchSignal.instance.dispatch(param1);
      }
      
      private function onMarketBuyResult(param1:MarketBuyResult) : void
      {
         MemMarketBuySignal.instance.dispatch(param1);
      }
      
      private function onMarketAddResult(param1:MarketAddResult) : void
      {
         MemMarketAddSignal.instance.dispatch(param1);
      }
      
      private function onMarketRemoveResult(param1:MarketRemoveResult) : void
      {
         MemMarketRemoveSignal.instance.dispatch(param1);
      }
      
      private function onMarketMyOffersResult(param1:MarketMyOffersResult) : void
      {
         MemMarketMyOffersSignal.instance.dispatch(param1);
      }
      
      public function marketSearch(param1:int) : void
      {
         var _loc2_:MarketSearch = this.messages.require(MARKET_SEARCH) as MarketSearch;
         _loc2_.itemType_ = param1;
         this.serverConnection.sendMessage(_loc2_);
      }
      
      public function marketRemove(param1:int) : void
      {
         var _loc2_:MarketRemove = this.messages.require(MARKET_REMOVE) as MarketRemove;
         _loc2_.id_ = param1;
         this.serverConnection.sendMessage(_loc2_);
      }
      
      public function marketMyOffers() : void
      {
         var _loc1_:MarketMyOffers = this.messages.require(MARKET_MY_OFFERS) as MarketMyOffers;
         this.serverConnection.sendMessage(_loc1_);
      }
      
      public function marketBuy(param1:int) : void
      {
         var _loc2_:MarketBuy = this.messages.require(MARKET_BUY) as MarketBuy;
         _loc2_.id_ = param1;
         this.serverConnection.sendMessage(_loc2_);
      }
      
      public function marketAdd(param1:Vector.<int>, param2:int, param3:int, param4:int) : void
      {
         var _loc5_:MarketAdd = this.messages.require(MARKET_ADD) as MarketAdd;
         _loc5_.slots_ = param1;
         _loc5_.price_ = param2;
         _loc5_.currency_ = param3;
         _loc5_.hours_ = param4;
         this.serverConnection.sendMessage(_loc5_);
      }
      
      public function onBountyMembersListGet(param1:BountyMemberListSend) : void
      {
         BountyMemberListSendSignal.instance.dispatch(param1);
      }
      
      private function onInvitedToParty(param1:InvitedToParty) : void
      {
         this.gs_.hudView.interactPanel.setOverride(new PartyInvitePanel(this.gs_,param1.name_,param1.partyId_));
         this.addTextLine.dispatch(new AddTextLineVO("","You have been invited by " + param1.name_ + " to join to his Party!\n If you wish to join type /paccept " + param1.partyId_));
      }
      
      public function joinParty(param1:String, param2:int) : void
      {
         var _loc3_:JoinParty = this.messages.require(JOIN_PARTY) as JoinParty;
         _loc3_.leader_ = param1;
         _loc3_.partyId = param2;
         this.serverConnection.sendMessage(_loc3_);
      }
   }
}
