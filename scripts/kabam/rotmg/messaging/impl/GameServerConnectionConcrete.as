package kabam.rotmg.messaging.impl
{
   import com.company.assembleegameclient.account.ui.Unboxing.UnboxResultBox;
   import com.company.assembleegameclient.game.GameSprite;
   import com.company.assembleegameclient.game.events.GuildResultEvent;
   import com.company.assembleegameclient.game.events.KeyInfoResponseSignal;
   import com.company.assembleegameclient.game.events.NameResultEvent;
   import com.company.assembleegameclient.game.events.ReconnectEvent;
   import com.company.assembleegameclient.map.AbstractMap;
   import com.company.assembleegameclient.map.GroundLibrary;
   import com.company.assembleegameclient.map.mapoverlay.CharacterStatusText;
   import com.company.assembleegameclient.objects.Container;
   import com.company.assembleegameclient.objects.FlashDescription;
   import com.company.assembleegameclient.objects.Friend;
   import com.company.assembleegameclient.objects.GameObject;
   import com.company.assembleegameclient.objects.Merchant;
   import com.company.assembleegameclient.objects.NameChanger;
   import com.company.assembleegameclient.objects.ObjectLibrary;
   import com.company.assembleegameclient.objects.ObjectProperties;
   import com.company.assembleegameclient.objects.Player;
   import com.company.assembleegameclient.objects.Projectile;
   import com.company.assembleegameclient.objects.ProjectileProperties;
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
   import com.company.assembleegameclient.objects.particles.RisingFuryEffect;
   import com.company.assembleegameclient.objects.particles.ShockeeEffect;
   import com.company.assembleegameclient.objects.particles.ShockerEffect;
   import com.company.assembleegameclient.objects.particles.StreamEffect;
   import com.company.assembleegameclient.objects.particles.TeleportEffect;
   import com.company.assembleegameclient.objects.particles.ThrowEffect;
   import com.company.assembleegameclient.objects.thrown.ThrowProjectileEffect;
   import com.company.assembleegameclient.parameters.Parameters;
   import com.company.assembleegameclient.sound.Music;
   import com.company.assembleegameclient.sound.SoundEffectLibrary;
   import com.company.assembleegameclient.ui.PicView;
   import com.company.assembleegameclient.ui.dialogs.Dialog;
   import com.company.assembleegameclient.ui.dialogs.NotEnoughFameDialog;
   import com.company.assembleegameclient.ui.lootNotification.LootNotification;
   import com.company.assembleegameclient.ui.panels.GambleRequestPanel;
   import com.company.assembleegameclient.ui.panels.GuildInvitePanel;
   import com.company.assembleegameclient.ui.panels.PartyInvitePanel;
   import com.company.assembleegameclient.ui.panels.TradeRequestPanel;
   import com.company.assembleegameclient.util.FreeList;
   import com.company.util.MoreStringUtil;
   import com.company.util.Random;
   import com.hurlant.crypto.Crypto;
   import com.hurlant.crypto.rsa.RSAKey;
   import com.hurlant.crypto.symmetric.ICipher;
   import com.hurlant.util.Base64;
   import com.hurlant.util.der.PEM;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.net.FileReference;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import kabam.lib.net.api.MessageMap;
   import kabam.lib.net.api.MessageProvider;
   import kabam.lib.net.impl.Message;
   import kabam.lib.net.impl.SocketServer;
   import kabam.rotmg.account.core.Account;
   import kabam.rotmg.account.core.view.PurchaseConfirmationDialog;
   import kabam.rotmg.arena.control.ArenaDeathSignal;
   import kabam.rotmg.arena.control.ImminentArenaWaveSignal;
   import kabam.rotmg.arena.model.CurrentArenaRunModel;
   import kabam.rotmg.arena.view.BattleSummaryDialog;
   import kabam.rotmg.arena.view.ContinueOrQuitDialog;
   import kabam.rotmg.chat.model.ChatMessage;
   import kabam.rotmg.classes.model.CharacterClass;
   import kabam.rotmg.classes.model.CharacterSkin;
   import kabam.rotmg.classes.model.CharacterSkinState;
   import kabam.rotmg.classes.model.ClassesModel;
   import kabam.rotmg.core.StaticInjectorContext;
   import kabam.rotmg.death.control.HandleDeathSignal;
   import kabam.rotmg.death.control.ZombifySignal;
   import kabam.rotmg.dialogs.control.CloseDialogsSignal;
   import kabam.rotmg.dialogs.control.OpenDialogSignal;
   import kabam.rotmg.game.focus.control.SetGameFocusSignal;
   import kabam.rotmg.game.model.GameModel;
   import kabam.rotmg.game.signals.AddSpeechBalloonSignal;
   import kabam.rotmg.game.signals.AddTextLineSignal;
   import kabam.rotmg.game.signals.GiftStatusUpdateSignal;
   import kabam.rotmg.game.signals.UpdateAlertStatusDisplaySignal;
   import kabam.rotmg.maploading.signals.ChangeMapSignal;
   import kabam.rotmg.maploading.signals.HideMapLoadingSignal;
   import kabam.rotmg.market.MarketItemsResultSignal;
   import kabam.rotmg.market.MarketResultSignal;
   import kabam.rotmg.messaging.impl.data.GroundTileData;
   import kabam.rotmg.messaging.impl.data.MarketOffer;
   import kabam.rotmg.messaging.impl.data.ObjectData;
   import kabam.rotmg.messaging.impl.data.ObjectStatusData;
   import kabam.rotmg.messaging.impl.data.SlotObjectData;
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
   import kabam.rotmg.messaging.impl.incoming.GambleStart;
   import kabam.rotmg.messaging.impl.incoming.GlobalNotification;
   import kabam.rotmg.messaging.impl.incoming.Goto;
   import kabam.rotmg.messaging.impl.incoming.GuildResult;
   import kabam.rotmg.messaging.impl.incoming.HomeDepotResult;
   import kabam.rotmg.messaging.impl.incoming.InvResult;
   import kabam.rotmg.messaging.impl.incoming.InvitedToGuild;
   import kabam.rotmg.messaging.impl.incoming.KeyInfoResponse;
   import kabam.rotmg.messaging.impl.incoming.LootNotification;
   import kabam.rotmg.messaging.impl.incoming.MapInfo;
   import kabam.rotmg.messaging.impl.incoming.MarketResult;
   import kabam.rotmg.messaging.impl.incoming.NameResult;
   import kabam.rotmg.messaging.impl.incoming.NewTick;
   import kabam.rotmg.messaging.impl.incoming.Notification;
   import kabam.rotmg.messaging.impl.incoming.PartyRequest;
   import kabam.rotmg.messaging.impl.incoming.PasswordPrompt;
   import kabam.rotmg.messaging.impl.incoming.Pic;
   import kabam.rotmg.messaging.impl.incoming.Ping;
   import kabam.rotmg.messaging.impl.incoming.PlaySound;
   import kabam.rotmg.messaging.impl.incoming.QuestFetchResponse;
   import kabam.rotmg.messaging.impl.incoming.QuestObjId;
   import kabam.rotmg.messaging.impl.incoming.QuestRedeemResponse;
   import kabam.rotmg.messaging.impl.incoming.QueuePing;
   import kabam.rotmg.messaging.impl.incoming.Reconnect;
   import kabam.rotmg.messaging.impl.incoming.ReskinUnlock;
   import kabam.rotmg.messaging.impl.incoming.SendAspectData;
   import kabam.rotmg.messaging.impl.incoming.ServerFull;
   import kabam.rotmg.messaging.impl.incoming.ServerPlayerShoot;
   import kabam.rotmg.messaging.impl.incoming.SetFocus;
   import kabam.rotmg.messaging.impl.incoming.ShowEffect;
   import kabam.rotmg.messaging.impl.incoming.ShowTrials;
   import kabam.rotmg.messaging.impl.incoming.SorForge;
   import kabam.rotmg.messaging.impl.incoming.SwitchMusic;
   import kabam.rotmg.messaging.impl.incoming.TradeAccepted;
   import kabam.rotmg.messaging.impl.incoming.TradeChanged;
   import kabam.rotmg.messaging.impl.incoming.TradeDone;
   import kabam.rotmg.messaging.impl.incoming.TradeRequested;
   import kabam.rotmg.messaging.impl.incoming.TradeStart;
   import kabam.rotmg.messaging.impl.incoming.UnboxResultPacket;
   import kabam.rotmg.messaging.impl.incoming.Update;
   import kabam.rotmg.messaging.impl.incoming.VerifyEmail;
   import kabam.rotmg.messaging.impl.incoming.arena.ArenaDeath;
   import kabam.rotmg.messaging.impl.incoming.arena.ImminentArenaWave;
   import kabam.rotmg.messaging.impl.outgoing.AcceptPartyInvite;
   import kabam.rotmg.messaging.impl.outgoing.AcceptTrade;
   import kabam.rotmg.messaging.impl.outgoing.AlertNotice;
   import kabam.rotmg.messaging.impl.outgoing.AoeAck;
   import kabam.rotmg.messaging.impl.outgoing.Buy;
   import kabam.rotmg.messaging.impl.outgoing.CancelTrade;
   import kabam.rotmg.messaging.impl.outgoing.ChangeGuildRank;
   import kabam.rotmg.messaging.impl.outgoing.ChangeTrade;
   import kabam.rotmg.messaging.impl.outgoing.CheckCredits;
   import kabam.rotmg.messaging.impl.outgoing.ChooseName;
   import kabam.rotmg.messaging.impl.outgoing.Create;
   import kabam.rotmg.messaging.impl.outgoing.CreateGuild;
   import kabam.rotmg.messaging.impl.outgoing.EditAccountList;
   import kabam.rotmg.messaging.impl.outgoing.EnemyHit;
   import kabam.rotmg.messaging.impl.outgoing.EnterArena;
   import kabam.rotmg.messaging.impl.outgoing.Escape;
   import kabam.rotmg.messaging.impl.outgoing.ForgeItem;
   import kabam.rotmg.messaging.impl.outgoing.GoToQuestRoom;
   import kabam.rotmg.messaging.impl.outgoing.GotoAck;
   import kabam.rotmg.messaging.impl.outgoing.GroundDamage;
   import kabam.rotmg.messaging.impl.outgoing.GroundTeleporter;
   import kabam.rotmg.messaging.impl.outgoing.GuildInvite;
   import kabam.rotmg.messaging.impl.outgoing.GuildRemove;
   import kabam.rotmg.messaging.impl.outgoing.Hello;
   import kabam.rotmg.messaging.impl.outgoing.HomeDepotInteraction;
   import kabam.rotmg.messaging.impl.outgoing.InvDrop;
   import kabam.rotmg.messaging.impl.outgoing.InvSwap;
   import kabam.rotmg.messaging.impl.outgoing.JoinGuild;
   import kabam.rotmg.messaging.impl.outgoing.KeyInfoRequest;
   import kabam.rotmg.messaging.impl.outgoing.LaunchRaid;
   import kabam.rotmg.messaging.impl.outgoing.Load;
   import kabam.rotmg.messaging.impl.outgoing.LockItem;
   import kabam.rotmg.messaging.impl.outgoing.MarkRequest;
   import kabam.rotmg.messaging.impl.outgoing.MarketCommand;
   import kabam.rotmg.messaging.impl.outgoing.Move;
   import kabam.rotmg.messaging.impl.outgoing.OtherHit;
   import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;
   import kabam.rotmg.messaging.impl.outgoing.PlayerHit;
   import kabam.rotmg.messaging.impl.outgoing.PlayerShoot;
   import kabam.rotmg.messaging.impl.outgoing.PlayerText;
   import kabam.rotmg.messaging.impl.outgoing.Pong;
   import kabam.rotmg.messaging.impl.outgoing.PotionStorageInteraction;
   import kabam.rotmg.messaging.impl.outgoing.QoLAction;
   import kabam.rotmg.messaging.impl.outgoing.QuestRedeem;
   import kabam.rotmg.messaging.impl.outgoing.QueuePong;
   import kabam.rotmg.messaging.impl.outgoing.RenameItem;
   import kabam.rotmg.messaging.impl.outgoing.RequestGamble;
   import kabam.rotmg.messaging.impl.outgoing.RequestPartyInvite;
   import kabam.rotmg.messaging.impl.outgoing.RequestTrade;
   import kabam.rotmg.messaging.impl.outgoing.Reskin;
   import kabam.rotmg.messaging.impl.outgoing.SetCondition;
   import kabam.rotmg.messaging.impl.outgoing.ShootAck;
   import kabam.rotmg.messaging.impl.outgoing.SorForgeRequest;
   import kabam.rotmg.messaging.impl.outgoing.SquareHit;
   import kabam.rotmg.messaging.impl.outgoing.Teleport;
   import kabam.rotmg.messaging.impl.outgoing.TrialsRequest;
   import kabam.rotmg.messaging.impl.outgoing.UnboxRequest;
   import kabam.rotmg.messaging.impl.outgoing.UseItem;
   import kabam.rotmg.messaging.impl.outgoing.UsePortal;
   import kabam.rotmg.minimap.control.UpdateGameObjectTileSignal;
   import kabam.rotmg.minimap.control.UpdateGroundTileSignal;
   import kabam.rotmg.minimap.model.UpdateGroundTileVO;
   import kabam.rotmg.questrewards.controller.QuestFetchCompleteSignal;
   import kabam.rotmg.questrewards.controller.QuestRedeemCompleteSignal;
   import kabam.rotmg.queue.control.ShowQueueSignal;
   import kabam.rotmg.queue.control.UpdateQueueSignal;
   import kabam.rotmg.servers.api.Server;
   import kabam.rotmg.sorForge.SorForgeModal;
   import kabam.rotmg.text.view.stringBuilder.LineBuilder;
   import kabam.rotmg.trialsMenu.TrialsPanel;
   import kabam.rotmg.ui.model.Key;
   import kabam.rotmg.ui.model.UpdateGameObjectTileVO;
   import kabam.rotmg.ui.signals.ShowHideKeyUISignal;
   import kabam.rotmg.ui.signals.ShowKeySignal;
   import kabam.rotmg.ui.signals.UpdateBackpackTabSignal;
   import kabam.rotmg.ui.signals.UpdateMarkTabSignal;
   import kabam.rotmg.ui.view.NotEnoughGoldDialog;
   import kabam.rotmg.ui.view.TitleView;
   import org.osflash.signals.Signal;
   import org.swiftsuspenders.Injector;
   import robotlegs.bender.framework.api.ILogger;
   import valor.ItemData;
   import valor.battlePass.BattlePassModel;
   import valor.battlePass.missions.Mission;
   import valor.battlePass.packets.ClaimBattlePassItem;
   import valor.battlePass.packets.MissionsReceive;
   import valor.battlePass.packets.RespriteItem;
   import valor.battlePass.resprites.RespriteData;
   
   public class GameServerConnectionConcrete
   {
      
      public static const FAILURE:int = 0;
      
      public static const CREATE_SUCCESS:int = 81;
      
      public static const CREATE:int = 12;
      
      public static const PLAYERSHOOT:int = 66;
      
      public static const MOVE:int = 16;
      
      public static const PLAYERTEXT:int = 47;
      
      public static const TEXT:int = 96;
      
      public static const SERVERPLAYERSHOOT:int = 92;
      
      public static const DAMAGE:int = 97;
      
      public static const UPDATE:int = 42;
      
      public static const UPDATEACK:int = 91;
      
      public static const NOTIFICATION:int = 33;
      
      public static const NEWTICK:int = 68;
      
      public static const INVSWAP:int = 25;
      
      public static const USEITEM:int = 1;
      
      public static const SHOWEFFECT:int = 38;
      
      public static const HELLO:int = 9;
      
      public static const GOTO:int = 30;
      
      public static const INVDROP:int = 18;
      
      public static const INVRESULT:int = 63;
      
      public static const RECONNECT:int = 14;
      
      public static const PING:int = 85;
      
      public static const PONG:int = 64;
      
      public static const MAPINFO:int = 74;
      
      public static const LOAD:int = 26;
      
      public static const PIC:int = 46;
      
      public static const SETCONDITION:int = 60;
      
      public static const TELEPORT:int = 45;
      
      public static const USEPORTAL:int = 6;
      
      public static const DEATH:int = 83;
      
      public static const BUY:int = 93;
      
      public static const BUYRESULT:int = 50;
      
      public static const AOE:int = 89;
      
      public static const GROUNDDAMAGE:int = 98;
      
      public static const PLAYERHIT:int = 10;
      
      public static const ENEMYHIT:int = 19;
      
      public static const AOEACK:int = 77;
      
      public static const SHOOTACK:int = 35;
      
      public static const OTHERHIT:int = 57;
      
      public static const SQUAREHIT:int = 13;
      
      public static const GOTOACK:int = 79;
      
      public static const EDITACCOUNTLIST:int = 62;
      
      public static const ACCOUNTLIST:int = 44;
      
      public static const QUESTOBJID:int = 28;
      
      public static const CHOOSENAME:int = 23;
      
      public static const NAMERESULT:int = 22;
      
      public static const CREATEGUILD:int = 95;
      
      public static const GUILDRESULT:int = 82;
      
      public static const GUILDREMOVE:int = 49;
      
      public static const GUILDINVITE:int = 41;
      
      public static const ALLYSHOOT:int = 36;
      
      public static const ENEMYSHOOT:int = 52;
      
      public static const REQUESTTRADE:int = 34;
      
      public static const TRADEREQUESTED:int = 80;
      
      public static const TRADESTART:int = 31;
      
      public static const CHANGETRADE:int = 55;
      
      public static const TRADECHANGED:int = 4;
      
      public static const ACCEPTTRADE:int = 3;
      
      public static const CANCELTRADE:int = 39;
      
      public static const TRADEDONE:int = 94;
      
      public static const TRADEACCEPTED:int = 78;
      
      public static const CLIENTSTAT:int = 75;
      
      public static const CHECKCREDITS:int = 20;
      
      public static const ESCAPE:int = 87;
      
      public static const FILE:int = 56;
      
      public static const INVITEDTOGUILD:int = 58;
      
      public static const JOINGUILD:int = 27;
      
      public static const CHANGEGUILDRANK:int = 11;
      
      public static const PLAYSOUND:int = 59;
      
      public static const GLOBAL_NOTIFICATION:int = 24;
      
      public static const RESKIN:int = 15;
      
      public static const NEW_ABILITY:int = 21;
      
      public static const ENTER_ARENA:int = 48;
      
      public static const IMMINENT_ARENA_WAVE:int = 5;
      
      public static const ARENA_DEATH:int = 17;
      
      public static const ACCEPT_ARENA_DEATH:int = 84;
      
      public static const VERIFY_EMAIL:int = 61;
      
      public static const RESKIN_UNLOCK:int = 40;
      
      public static const PASSWORD_PROMPT:int = 69;
      
      public static const QUEST_FETCH_ASK:int = 51;
      
      public static const QUEST_REDEEM:int = 37;
      
      public static const QUEST_FETCH_RESPONSE:int = 65;
      
      public static const QUEST_REDEEM_RESPONSE:int = 88;
      
      public static const SERVER_FULL:int = 110;
      
      public static const QUEUE_PING:int = 111;
      
      public static const QUEUE_PONG:int = 112;
      
      public static const MARKET_COMMAND:int = 99;
      
      public static const QUEST_ROOM_MSG:int = 155;
      
      public static const KEY_INFO_REQUEST:int = 151;
      
      public static const KEY_INFO_RESPONSE:int = 152;
      
      public static const MARKET_RESULT:int = 100;
      
      public static const SET_FOCUS:int = 108;
      
      public static const SWITCH_MUSIC:int = 106;
      
      public static const LAUNCH_RAID:int = 156;
      
      public static const SORFORGE:int = 158;
      
      public static const SORFORGEREQUEST:int = 159;
      
      public static const FORGEITEM:int = 160;
      
      public static const UNBOXREQUEST:int = 161;
      
      public static const UNBOXRESULT:int = 162;
      
      public static const ALERTNOTICE:int = 163;
      
      public static const MARKREQUEST:int = 164;
      
      public static const QOLACTION:int = 165;
      
      public static const GAMBLESTART:int = 166;
      
      public static const REQUESTGAMBLE:int = 167;
      
      public static const REQUESTPARTYINVITE:int = 168;
      
      public static const PARTYREQUEST:int = 169;
      
      public static const PARTYACCEPTED:int = 170;
      
      public static const LOOTNOTIFICATION:int = 171;
      
      public static const SHOWTRIALS:int = 172;
      
      public static const TRIALSREQUEST:int = 173;
      
      public static const POTION_STORAGE_INTERACTION:int = 174;
      
      public static const RENAME_ITEM_MESSAGE:int = 175;
      
      public static const HOMEDEPOTINTERACTION:int = 176;
      
      public static const HOMEDEPOTINTERACTIONRESULT:int = 177;
      
      public static const GROUNDTELEPORTER:int = 178;
      
      public static const CLAIM_BATTLE_PASS_ITEM:int = 179;
      
      public static const MISSIONS_RECEIVE:int = 180;
      
      public static const RESPRITE_ITEM:int = 181;
      
      public static const LOCK_ITEM:int = 182;
      
      public static const SEND_ASPECT_DATA:int = 183;
      
      public static var instance:GameServerConnectionConcrete;
      
      private static const TO_MILLISECONDS:int = 1000;
       
      
      public var changeMapSignal:Signal;
      
      public var gs:GameSprite;
      
      public var server_:Server;
      
      public var gameId_:int;
      
      public var createCharacter_:Boolean;
      
      public var charId_:int;
      
      public var keyTime_:int;
      
      public var key_:ByteArray;
      
      public var mapJSON_:String;
      
      public var isFromArena_:Boolean = false;
      
      public var lastTickId_:int = -1;
      
      public var jitterWatcher_:JitterWatcher;
      
      public var serverConnection:SocketServer;
      
      public var outstandingBuy_:Boolean;
      
      public var petId:int;
      
      private var messages:MessageProvider;
      
      private var playerId_:int = -1;
      
      public var player:Player;
      
      private var retryConnection_:Boolean = true;
      
      private var rand_:Random = null;
      
      private var giftChestUpdateSignal:GiftStatusUpdateSignal;
      
      private var alertStatusUpdateSignal:UpdateAlertStatusDisplaySignal;
      
      private var death:Death;
      
      private var retryTimer_:Timer;
      
      private var delayBeforeReconnect:int = 2;
      
      private var addTextLine:AddTextLineSignal;
      
      private var addSpeechBalloon:AddSpeechBalloonSignal;
      
      private var updateGroundTileSignal:UpdateGroundTileSignal;
      
      private var updateGameObjectTileSignal:UpdateGameObjectTileSignal;
      
      private var logger:ILogger;
      
      private var handleDeath:HandleDeathSignal;
      
      private var zombify:ZombifySignal;
      
      private var setGameFocus:SetGameFocusSignal;
      
      private var updateBackpackTab:UpdateBackpackTabSignal;
      
      private var updateMarkTab:UpdateMarkTabSignal;
      
      private var closeDialogs:CloseDialogsSignal;
      
      private var openDialog:OpenDialogSignal;
      
      private var arenaDeath:ArenaDeathSignal;
      
      private var imminentWave:ImminentArenaWaveSignal;
      
      private var questFetchComplete:QuestFetchCompleteSignal;
      
      private var questRedeemComplete:QuestRedeemCompleteSignal;
      
      private var keyInfoResponse:KeyInfoResponseSignal;
      
      private var currentArenaRun:CurrentArenaRunModel;
      
      private var classesModel:ClassesModel;
      
      private var injector:Injector;
      
      private var model:GameModel;
      
      public var battlePassModel:BattlePassModel;
      
      private var lastUseTime:int;
      
      public function GameServerConnectionConcrete(_arg1:GameSprite, _arg2:Server, _arg3:int, _arg4:Boolean, _arg5:int, _arg6:int, _arg7:ByteArray, _arg8:String, _arg9:Boolean)
      {
         super();
         this.injector = StaticInjectorContext.getInjector();
         this.giftChestUpdateSignal = this.injector.getInstance(GiftStatusUpdateSignal);
         this.alertStatusUpdateSignal = this.injector.getInstance(UpdateAlertStatusDisplaySignal);
         this.addTextLine = this.injector.getInstance(AddTextLineSignal);
         this.addSpeechBalloon = this.injector.getInstance(AddSpeechBalloonSignal);
         this.updateGroundTileSignal = this.injector.getInstance(UpdateGroundTileSignal);
         this.updateGameObjectTileSignal = this.injector.getInstance(UpdateGameObjectTileSignal);
         this.updateBackpackTab = StaticInjectorContext.getInjector().getInstance(UpdateBackpackTabSignal);
         this.updateMarkTab = StaticInjectorContext.getInjector().getInstance(UpdateMarkTabSignal);
         this.closeDialogs = this.injector.getInstance(CloseDialogsSignal);
         changeMapSignal = this.injector.getInstance(ChangeMapSignal);
         this.openDialog = this.injector.getInstance(OpenDialogSignal);
         this.arenaDeath = this.injector.getInstance(ArenaDeathSignal);
         this.imminentWave = this.injector.getInstance(ImminentArenaWaveSignal);
         this.questFetchComplete = this.injector.getInstance(QuestFetchCompleteSignal);
         this.questRedeemComplete = this.injector.getInstance(QuestRedeemCompleteSignal);
         this.keyInfoResponse = this.injector.getInstance(KeyInfoResponseSignal);
         this.logger = this.injector.getInstance(ILogger);
         this.handleDeath = this.injector.getInstance(HandleDeathSignal);
         this.zombify = this.injector.getInstance(ZombifySignal);
         this.setGameFocus = this.injector.getInstance(SetGameFocusSignal);
         this.classesModel = this.injector.getInstance(ClassesModel);
         serverConnection = this.injector.getInstance(SocketServer);
         this.messages = this.injector.getInstance(MessageProvider);
         this.model = this.injector.getInstance(GameModel);
         this.currentArenaRun = this.injector.getInstance(CurrentArenaRunModel);
         this.battlePassModel = new BattlePassModel();
         gs = _arg1;
         server_ = _arg2;
         gameId_ = _arg3;
         createCharacter_ = _arg4;
         charId_ = _arg5;
         keyTime_ = _arg6;
         key_ = _arg7;
         mapJSON_ = _arg8;
         isFromArena_ = _arg9;
         instance = this;
      }
      
      public function disconnect() : void
      {
         this.removeServerConnectionListeners();
         this.unmapMessages();
         serverConnection.disconnect();
      }
      
      private function removeServerConnectionListeners() : void
      {
         serverConnection.connected.remove(this.onConnected);
         serverConnection.closed.remove(this.onClosed);
         serverConnection.error.remove(this.onError);
      }
      
      public function connect() : void
      {
         this.addServerConnectionListeners();
         this.mapMessages();
         var _local1:ChatMessage = new ChatMessage();
         _local1.name = "*Client*";
         _local1.text = "chat.connectingTo";
         var _local2:String = server_.name;
         if(_local2 == "{\"text\":\"server.vault\"}")
         {
            _local2 = "server.vault";
         }
         _local2 = LineBuilder.getLocalizedStringFromKey(_local2);
         _local1.tokens = {"serverName":_local2};
         this.addTextLine.dispatch(_local1);
         serverConnection.connect(server_.address,server_.port);
      }
      
      public function addServerConnectionListeners() : void
      {
         serverConnection.connected.add(this.onConnected);
         serverConnection.closed.add(this.onClosed);
         serverConnection.error.add(this.onError);
      }
      
      public function mapMessages() : void
      {
         var _local1:MessageMap = this.injector.getInstance(MessageMap);
         _local1.map(12).toMessage(Create);
         _local1.map(66).toMessage(PlayerShoot);
         _local1.map(16).toMessage(Move);
         _local1.map(47).toMessage(PlayerText);
         _local1.map(91).toMessage(Message);
         _local1.map(25).toMessage(InvSwap);
         _local1.map(1).toMessage(UseItem);
         _local1.map(9).toMessage(Hello);
         _local1.map(18).toMessage(InvDrop);
         _local1.map(64).toMessage(Pong);
         _local1.map(26).toMessage(Load);
         _local1.map(60).toMessage(SetCondition);
         _local1.map(45).toMessage(Teleport);
         _local1.map(6).toMessage(UsePortal);
         _local1.map(93).toMessage(Buy);
         _local1.map(10).toMessage(PlayerHit);
         _local1.map(19).toMessage(EnemyHit);
         _local1.map(77).toMessage(AoeAck);
         _local1.map(35).toMessage(ShootAck);
         _local1.map(57).toMessage(OtherHit);
         _local1.map(13).toMessage(SquareHit);
         _local1.map(79).toMessage(GotoAck);
         _local1.map(98).toMessage(GroundDamage);
         _local1.map(178).toMessage(GroundTeleporter);
         _local1.map(23).toMessage(ChooseName);
         _local1.map(95).toMessage(CreateGuild);
         _local1.map(49).toMessage(GuildRemove);
         _local1.map(41).toMessage(GuildInvite);
         _local1.map(34).toMessage(RequestTrade);
         _local1.map(168).toMessage(RequestPartyInvite);
         _local1.map(55).toMessage(ChangeTrade);
         _local1.map(3).toMessage(AcceptTrade);
         _local1.map(39).toMessage(CancelTrade);
         _local1.map(20).toMessage(CheckCredits);
         _local1.map(87).toMessage(Escape);
         _local1.map(155).toMessage(GoToQuestRoom);
         _local1.map(27).toMessage(JoinGuild);
         _local1.map(11).toMessage(ChangeGuildRank);
         _local1.map(62).toMessage(EditAccountList);
         _local1.map(48).toMessage(EnterArena);
         _local1.map(84).toMessage(OutgoingMessage);
         _local1.map(51).toMessage(OutgoingMessage);
         _local1.map(37).toMessage(QuestRedeem);
         _local1.map(151).toMessage(KeyInfoRequest);
         _local1.map(156).toMessage(LaunchRaid);
         _local1.map(159).toMessage(SorForgeRequest);
         _local1.map(160).toMessage(ForgeItem);
         _local1.map(163).toMessage(AlertNotice);
         _local1.map(165).toMessage(QoLAction);
         _local1.map(164).toMessage(MarkRequest);
         _local1.map(161).toMessage(UnboxRequest);
         _local1.map(99).toMessage(MarketCommand);
         _local1.map(167).toMessage(RequestGamble);
         _local1.map(170).toMessage(AcceptPartyInvite);
         _local1.map(0).toMessage(Failure).toMethod(this.onFailure);
         _local1.map(81).toMessage(CreateSuccess).toMethod(this.onCreateSuccess);
         _local1.map(92).toMessage(ServerPlayerShoot).toMethod(this.onServerPlayerShoot);
         _local1.map(97).toMessage(Damage).toMethod(this.onDamage);
         _local1.map(42).toMessage(Update).toMethod(this.onUpdate);
         _local1.map(33).toMessage(Notification).toMethod(this.onNotification);
         _local1.map(24).toMessage(GlobalNotification).toMethod(this.onGlobalNotification);
         _local1.map(68).toMessage(NewTick).toMethod(this.onNewTick);
         _local1.map(38).toMessage(ShowEffect).toMethod(this.onShowEffect);
         _local1.map(30).toMessage(Goto).toMethod(this.onGoto);
         _local1.map(63).toMessage(InvResult).toMethod(this.onInvResult);
         _local1.map(14).toMessage(Reconnect).toMethod(this.onReconnect);
         _local1.map(85).toMessage(Ping).toMethod(this.onPing);
         _local1.map(74).toMessage(MapInfo).toMethod(this.onMapInfo);
         _local1.map(46).toMessage(Pic).toMethod(this.onPic);
         _local1.map(83).toMessage(Death).toMethod(this.onDeath);
         _local1.map(50).toMessage(BuyResult).toMethod(this.onBuyResult);
         _local1.map(89).toMessage(Aoe).toMethod(this.onAoe);
         _local1.map(44).toMessage(AccountList).toMethod(this.onAccountList);
         _local1.map(28).toMessage(QuestObjId).toMethod(this.onQuestObjId);
         _local1.map(22).toMessage(NameResult).toMethod(this.onNameResult);
         _local1.map(82).toMessage(GuildResult).toMethod(this.onGuildResult);
         _local1.map(36).toMessage(AllyShoot).toMethod(this.onAllyShoot);
         _local1.map(52).toMessage(EnemyShoot).toMethod(this.onEnemyShoot);
         _local1.map(80).toMessage(TradeRequested).toMethod(this.onTradeRequested);
         _local1.map(166).toMessage(GambleStart).toMethod(this.onGambleRequest);
         _local1.map(169).toMessage(PartyRequest).toMethod(this.onPartyInviteRequest);
         _local1.map(31).toMessage(TradeStart).toMethod(this.onTradeStart);
         _local1.map(4).toMessage(TradeChanged).toMethod(this.onTradeChanged);
         _local1.map(94).toMessage(TradeDone).toMethod(this.onTradeDone);
         _local1.map(78).toMessage(TradeAccepted).toMethod(this.onTradeAccepted);
         _local1.map(75).toMessage(ClientStat).toMethod(this.onClientStat);
         _local1.map(56).toMessage(File).toMethod(this.onFile);
         _local1.map(58).toMessage(InvitedToGuild).toMethod(this.onInvitedToGuild);
         _local1.map(59).toMessage(PlaySound).toMethod(this.onPlaySound);
         _local1.map(5).toMessage(ImminentArenaWave).toMethod(this.onImminentArenaWave);
         _local1.map(17).toMessage(ArenaDeath).toMethod(this.onArenaDeath);
         _local1.map(61).toMessage(VerifyEmail).toMethod(this.onVerifyEmail);
         _local1.map(40).toMessage(ReskinUnlock).toMethod(this.onReskinUnlock);
         _local1.map(69).toMessage(PasswordPrompt).toMethod(this.onPasswordPrompt);
         _local1.map(65).toMessage(QuestFetchResponse).toMethod(this.onQuestFetchResponse);
         _local1.map(88).toMessage(QuestRedeemResponse).toMethod(this.onQuestRedeemResponse);
         _local1.map(152).toMessage(KeyInfoResponse).toMethod(this.onKeyInfoResponse);
         _local1.map(108).toMessage(SetFocus).toMethod(this.setFocus);
         _local1.map(112).toMessage(QueuePong);
         _local1.map(110).toMessage(ServerFull).toMethod(this.HandleServerFull);
         _local1.map(111).toMessage(QueuePing).toMethod(this.HandleQueuePing);
         _local1.map(106).toMessage(SwitchMusic).toMethod(this.onSwitchMusic);
         _local1.map(158).toMessage(SorForge).toMethod(this.onSorForge);
         _local1.map(162).toMessage(UnboxResultPacket).toMethod(this.unboxResult);
         _local1.map(100).toMessage(MarketResult).toMethod(this.HandleMarketResult);
         _local1.map(171).toMessage(kabam.rotmg.messaging.impl.incoming.LootNotification).toMethod(this.lootNotif);
         _local1.map(172).toMessage(ShowTrials).toMethod(this.onTrialsOpen);
         _local1.map(173).toMessage(TrialsRequest);
         _local1.map(174).toMessage(PotionStorageInteraction);
         _local1.map(175).toMessage(RenameItem);
         _local1.map(176).toMessage(HomeDepotInteraction);
         _local1.map(177).toMessage(HomeDepotResult).toMethod(this.onHomeDepotResult);
         _local1.map(179).toMessage(ClaimBattlePassItem);
         _local1.map(180).toMessage(MissionsReceive).toMethod(onMissionsReceive);
         _local1.map(181).toMessage(RespriteItem);
         _local1.map(182).toMessage(LockItem);
         _local1.map(183).toMessage(SendAspectData).toMethod(this.onSendAspectData);
      }
      
      private function onMissionsReceive(missionsReceive:MissionsReceive) : void
      {
         var missionStruct:* = null;
         for each(var missionId in missionsReceive.missionsDrop)
         {
            if(battlePassModel.missions[missionId])
            {
               battlePassModel.missions[missionId] = null;
               delete battlePassModel.missions[missionId];
            }
         }
         for each(var mission in missionsReceive.missionsUpdate)
         {
            missionStruct = new Mission(mission);
            battlePassModel.missions[missionStruct.missionId] = missionStruct;
         }
      }
      
      private function onHomeDepotResult(_arg1:HomeDepotResult) : void
      {
      }
      
      private function onSwitchMusic(sm:SwitchMusic) : void
      {
         Music.load(sm.music);
      }
      
      private function onSendAspectData(ad:SendAspectData) : void
      {
         if(player != null)
         {
            player.AnubisStacks = ad != null ? ad.anubisStacks : 0;
         }
      }
      
      private function HandleServerFull(_arg1:ServerFull) : void
      {
         this.injector.getInstance(ShowQueueSignal).dispatch();
         this.injector.getInstance(UpdateQueueSignal).dispatch(_arg1.position_,_arg1.count_);
      }
      
      private function HandleQueuePing(_arg1:QueuePing) : void
      {
         this.injector.getInstance(UpdateQueueSignal).dispatch(_arg1.position_,_arg1.count_);
         var qp:QueuePong = this.messages.require(112) as QueuePong;
         qp.serial_ = _arg1.serial_;
         qp.time_ = getTimer();
         serverConnection.sendMessage(qp);
      }
      
      private function unmapMessages() : void
      {
         var _local1:MessageMap = this.injector.getInstance(MessageMap);
         _local1.unmap(12);
         _local1.unmap(66);
         _local1.unmap(16);
         _local1.unmap(47);
         _local1.unmap(91);
         _local1.unmap(25);
         _local1.unmap(1);
         _local1.unmap(9);
         _local1.unmap(18);
         _local1.unmap(64);
         _local1.unmap(26);
         _local1.unmap(60);
         _local1.unmap(45);
         _local1.unmap(6);
         _local1.unmap(93);
         _local1.unmap(10);
         _local1.unmap(19);
         _local1.unmap(77);
         _local1.unmap(35);
         _local1.unmap(57);
         _local1.unmap(13);
         _local1.unmap(79);
         _local1.unmap(98);
         _local1.unmap(178);
         _local1.unmap(23);
         _local1.unmap(95);
         _local1.unmap(49);
         _local1.unmap(41);
         _local1.unmap(34);
         _local1.unmap(168);
         _local1.unmap(55);
         _local1.unmap(3);
         _local1.unmap(39);
         _local1.unmap(20);
         _local1.unmap(87);
         _local1.unmap(155);
         _local1.unmap(27);
         _local1.unmap(11);
         _local1.unmap(62);
         _local1.unmap(48);
         _local1.unmap(84);
         _local1.unmap(51);
         _local1.unmap(37);
         _local1.unmap(151);
         _local1.unmap(156);
         _local1.unmap(159);
         _local1.unmap(160);
         _local1.unmap(163);
         _local1.unmap(165);
         _local1.unmap(164);
         _local1.unmap(161);
         _local1.unmap(99);
         _local1.unmap(167);
         _local1.unmap(170);
         _local1.unmap(0);
         _local1.unmap(81);
         _local1.unmap(92);
         _local1.unmap(97);
         _local1.unmap(42);
         _local1.unmap(33);
         _local1.unmap(24);
         _local1.unmap(68);
         _local1.unmap(38);
         _local1.unmap(30);
         _local1.unmap(63);
         _local1.unmap(14);
         _local1.unmap(85);
         _local1.unmap(74);
         _local1.unmap(46);
         _local1.unmap(83);
         _local1.unmap(50);
         _local1.unmap(89);
         _local1.unmap(44);
         _local1.unmap(28);
         _local1.unmap(22);
         _local1.unmap(82);
         _local1.unmap(36);
         _local1.unmap(52);
         _local1.unmap(80);
         _local1.unmap(166);
         _local1.unmap(169);
         _local1.unmap(31);
         _local1.unmap(4);
         _local1.unmap(94);
         _local1.unmap(78);
         _local1.unmap(75);
         _local1.unmap(56);
         _local1.unmap(58);
         _local1.unmap(59);
         _local1.unmap(5);
         _local1.unmap(17);
         _local1.unmap(61);
         _local1.unmap(40);
         _local1.unmap(69);
         _local1.unmap(65);
         _local1.unmap(88);
         _local1.unmap(152);
         _local1.unmap(108);
         _local1.unmap(112);
         _local1.unmap(110);
         _local1.unmap(111);
         _local1.unmap(106);
         _local1.unmap(158);
         _local1.unmap(162);
         _local1.unmap(100);
         _local1.unmap(171);
         _local1.unmap(172);
         _local1.unmap(173);
         _local1.unmap(174);
         _local1.unmap(176);
         _local1.unmap(177);
         _local1.unmap(175);
         _local1.unmap(179);
         _local1.unmap(180);
         _local1.unmap(181);
         _local1.unmap(182);
         _local1.unmap(183);
      }
      
      private function encryptConnection() : void
      {
         var _local1:* = null;
         var _local2:* = null;
         _local1 = Crypto.getCipher("rc4",MoreStringUtil.hexStringToByteArray("BA15DE"));
         _local2 = Crypto.getCipher("rc4",MoreStringUtil.hexStringToByteArray("612a806cac78114ba5013cb531"));
         serverConnection.setOutgoingCipher(_local1);
         serverConnection.setIncomingCipher(_local2);
      }
      
      public function PotionInteraction(type:int, action:int) : void
      {
         var _local_1:PotionStorageInteraction = this.messages.require(174) as PotionStorageInteraction;
         _local_1.type_ = type;
         _local_1.action_ = action;
         this.serverConnection.sendMessage(_local_1);
      }
      
      public function getNextInt(min:uint, max:uint) : uint
      {
         return this.rand_.nextIntRange(min,max);
      }
      
      public function enableJitterWatcher() : void
      {
         if(jitterWatcher_ == null)
         {
            jitterWatcher_ = new JitterWatcher();
         }
      }
      
      public function disableJitterWatcher() : void
      {
         if(jitterWatcher_ != null)
         {
            jitterWatcher_ = null;
         }
      }
      
      private function create() : void
      {
         var _local1:CharacterClass = this.classesModel.getSelected();
         var _local2:Create = this.messages.require(12) as Create;
         _local2.classType = _local1.id;
         _local2.skinType = _local1.skins.getSelectedSkin().id;
         serverConnection.sendMessage(_local2);
      }
      
      private function load() : void
      {
         var _local1:Load = this.messages.require(26) as Load;
         _local1.charId_ = charId_;
         _local1.isFromArena_ = isFromArena_;
         serverConnection.sendMessage(_local1);
         if(isFromArena_)
         {
            this.openDialog.dispatch(new BattleSummaryDialog());
         }
      }
      
      private function onSorForge(_arg1:SorForge) : void
      {
         var _local_2:* = null;
         if(_arg1.isForge)
         {
            _local_2 = StaticInjectorContext.getInjector().getInstance(OpenDialogSignal);
            _local_2.dispatch(new SorForgeModal());
         }
      }
      
      private function unboxResult(_arg1:UnboxResultPacket) : void
      {
         this.openDialog.dispatch(new UnboxResultBox(this.gs,_arg1.items_));
      }
      
      public function playerShoot(_arg1:int, _arg2:Projectile) : void
      {
         var _local3:PlayerShoot = this.messages.require(66) as PlayerShoot;
         _local3.time_ = _arg1;
         _local3.bulletId_ = _arg2.bulletId;
         _local3.containerType_ = _arg2.containerType;
         _local3.startingPos_.x_ = _arg2.x_;
         _local3.startingPos_.y_ = _arg2.y_;
         _local3.angle_ = _arg2.angle;
         serverConnection.sendMessage(_local3);
      }
      
      public function playerHit(_arg1:int, _arg2:int) : void
      {
         var _local3:PlayerHit = this.messages.require(10) as PlayerHit;
         _local3.bulletId_ = _arg1;
         _local3.objectId_ = _arg2;
         serverConnection.sendMessage(_local3);
      }
      
      public function enemyHit(_arg1:int, _arg2:int, _arg3:int, _arg4:Boolean) : void
      {
         var _local5:EnemyHit;
         (_local5 = this.messages.require(19) as EnemyHit).time_ = _arg1;
         _local5.bulletId_ = _arg2;
         _local5.targetId_ = _arg3;
         _local5.kill_ = _arg4;
         serverConnection.sendMessage(_local5);
      }
      
      public function otherHit(_arg1:int, _arg2:int, _arg3:int, _arg4:int) : void
      {
         var _local5:OtherHit;
         (_local5 = this.messages.require(57) as OtherHit).time_ = _arg1;
         _local5.bulletId_ = _arg2;
         _local5.objectId_ = _arg3;
         _local5.targetId_ = _arg4;
         serverConnection.sendMessage(_local5);
      }
      
      public function squareHit(_arg1:int, _arg2:int, _arg3:int) : void
      {
         var _local4:SquareHit;
         (_local4 = this.messages.require(13) as SquareHit).time_ = _arg1;
         _local4.bulletId_ = _arg2;
         _local4.objectId_ = _arg3;
         serverConnection.sendMessage(_local4);
      }
      
      public function aoeAck(_arg1:int, _arg2:Number, _arg3:Number) : void
      {
         var _local4:AoeAck;
         (_local4 = this.messages.require(77) as AoeAck).time_ = _arg1;
         _local4.position_.x_ = _arg2;
         _local4.position_.y_ = _arg3;
         serverConnection.sendMessage(_local4);
      }
      
      public function groundDamage(_arg1:int, _arg2:Number, _arg3:Number) : void
      {
         var _local4:GroundDamage;
         (_local4 = this.messages.require(98) as GroundDamage).time_ = _arg1;
         _local4.position_.x_ = _arg2;
         _local4.position_.y_ = _arg3;
         serverConnection.sendMessage(_local4);
      }
      
      public function groundTeleport(_arg1:int, _arg2:Number, _arg3:Number) : void
      {
         var _local4:GroundTeleporter;
         (_local4 = this.messages.require(178) as GroundTeleporter).time_ = _arg1;
         _local4.position_.x_ = _arg2;
         _local4.position_.y_ = _arg3;
         serverConnection.sendMessage(_local4);
      }
      
      public function shootAck(_arg1:int) : void
      {
         var _local2:ShootAck = this.messages.require(35) as ShootAck;
         _local2.time_ = _arg1;
         serverConnection.sendMessage(_local2);
      }
      
      public function playerText(_arg1:String) : void
      {
         var _local2:PlayerText = this.messages.require(47) as PlayerText;
         _local2.text_ = _arg1;
         serverConnection.sendMessage(_local2);
      }
      
      public function invSwap(plr:Player, go1:GameObject, go1Slot:int, go1ItemData:ItemData, go2:GameObject, go2Slot:int, go2ItemData:ItemData) : Boolean
      {
         if(!gs)
         {
            return false;
         }
         var swap:InvSwap;
         (swap = this.messages.require(25) as InvSwap).time_ = gs.lastUpdate_;
         swap.position_.x_ = plr.x_;
         swap.position_.y_ = plr.y_;
         swap.slotObject1_.objectId_ = go1.objectId;
         swap.slotObject1_.slotId_ = go1Slot;
         swap.slotObject1_.itemData_ = go1ItemData.toString();
         swap.slotObject2_.objectId_ = go2.objectId;
         swap.slotObject2_.slotId_ = go2Slot;
         swap.slotObject2_.itemData_ = go2ItemData.toString();
         serverConnection.sendMessage(swap);
         var temp:ItemData = go1.equipment_[go1Slot];
         go1.equipment_[go1Slot] = go2.equipment_[go2Slot];
         go2.equipment_[go2Slot] = temp;
         SoundEffectLibrary.play("inventory_move_item");
         return true;
      }
      
      public function invSwapPotion(_arg1:Player, _arg2:GameObject, _arg3:int, _arg4:ItemData, _arg5:GameObject, _arg6:int, _arg7:ItemData) : Boolean
      {
         if(!gs)
         {
            return false;
         }
         var _local8:InvSwap;
         (_local8 = this.messages.require(25) as InvSwap).time_ = gs.lastUpdate_;
         _local8.position_.x_ = _arg1.x_;
         _local8.position_.y_ = _arg1.y_;
         _local8.slotObject1_.objectId_ = _arg2.objectId;
         _local8.slotObject1_.slotId_ = _arg3;
         _local8.slotObject1_.itemData_ = _arg4.toString();
         _local8.slotObject2_.objectId_ = _arg5.objectId;
         _local8.slotObject2_.slotId_ = _arg6;
         _local8.slotObject2_.itemData_ = _arg7.toString();
         _arg2.equipment_[_arg3] = new ItemData();
         if(_arg4.objectType == 2594)
         {
            _arg1.healthPotionCount_++;
         }
         else if(_arg4.objectType == 2595)
         {
            _arg1.magicPotionCount_++;
         }
         serverConnection.sendMessage(_local8);
         SoundEffectLibrary.play("inventory_move_item");
         return true;
      }
      
      public function invDrop(_arg1:GameObject, _arg2:int, _arg3:ItemData) : void
      {
         var _local4:InvDrop;
         (_local4 = this.messages.require(18) as InvDrop).slotObject_.objectId_ = _arg1.objectId;
         _local4.slotObject_.slotId_ = _arg2;
         _local4.slotObject_.itemData_ = _arg3.toString();
         serverConnection.sendMessage(_local4);
         if(_arg2 != 254 && _arg2 != 255)
         {
            _arg1.equipment_[_arg2] = new ItemData();
         }
      }
      
      public function useItem(_arg1:int, _arg2:int, _arg3:int, _arg4:ItemData, _arg5:Number, _arg6:Number, _arg7:int) : void
      {
         var _local8:UseItem;
         (_local8 = this.messages.require(1) as UseItem).time_ = _arg1;
         _local8.slotObject_.objectId_ = _arg2;
         _local8.slotObject_.slotId_ = _arg3;
         _local8.slotObject_.itemData_ = _arg4.toString();
         _local8.itemUsePos_.x_ = _arg5;
         _local8.itemUsePos_.y_ = _arg6;
         _local8.useType_ = _arg7;
         serverConnection.sendMessage(_local8);
      }
      
      public function useItem_new(go:GameObject, slot:int) : Boolean
      {
         var player:* = null;
         var stats:* = undefined;
         var baseStat:int = 0;
         var consumeResult:* = null;
         var postMaxOffset:int = 0;
         var stat:int = 0;
         var itemData:ItemData = go.equipment_[slot];
         var itemXML:XML;
         if((itemXML = ObjectLibrary.xmlLibrary_[itemData.objectType]) && !go.isPaused())
         {
            if(getTimer() <= this.lastUseTime)
            {
               if(itemXML.hasOwnProperty("InvUse"))
               {
                  this.addTextLine.dispatch(ChatMessage.make("","Please wait \'" + ((this.lastUseTime - getTimer()) / 1000).toFixed(0) + "\' more seconds before attempting to use this item."));
               }
               SoundEffectLibrary.play("error");
               return false;
            }
            this.lastUseTime = getTimer() + (!!itemXML.hasOwnProperty("Cooldown") ? itemXML.Cooldown * 1000 : Number(550));
            if(itemXML.Activate == "IncrementStat" || itemXML.Activate == "PowerStat")
            {
               player = go is Player ? go as Player : this.player;
               if((stats = StatData.statToPlayerValues(itemXML.Activate.@stat,player)) == null)
               {
                  SoundEffectLibrary.play("error");
                  return false;
               }
               baseStat = stats[0] - stats[1];
               if(itemXML.Activate == "PowerStat")
               {
                  if(!player.ascended)
                  {
                     this.addTextLine.dispatch(ChatMessage.make("","You must have ascension enabled in order to consume vials."));
                     SoundEffectLibrary.play("error");
                     return false;
                  }
                  postMaxOffset = itemXML.Activate.@stat == 0 || itemXML.Activate.@stat == 3 ? 50 : 10;
                  if(baseStat == stats[2] + postMaxOffset)
                  {
                     this.addTextLine.dispatch(ChatMessage.make("","\'" + itemXML.attribute("id") + "\' not consumed." + " You already fully ascended this stat."));
                     SoundEffectLibrary.play("error");
                     return false;
                  }
                  if(baseStat + int(itemXML.Activate.@amount) == stats[2] + postMaxOffset)
                  {
                     consumeResult = "You are now fully ascended in this stat.";
                  }
                  else
                  {
                     consumeResult = stats[2] + postMaxOffset - (baseStat + int(itemXML.Activate.@amount)) + " left to fully ascend this stat.";
                  }
                  this.addTextLine.dispatch(ChatMessage.make("","\'" + itemXML.attribute("id") + "\' consumed. " + consumeResult));
               }
               if(itemXML.Activate == "IncrementStat")
               {
                  if(baseStat >= stats[2])
                  {
                     stat = itemXML.Activate.@stat;
                     switch(stat)
                     {
                        case 0:
                           PotionInteraction(0,0);
                           break;
                        case 3:
                           PotionInteraction(1,0);
                           break;
                        case 20:
                           PotionInteraction(2,0);
                           break;
                        case 21:
                           PotionInteraction(3,0);
                           break;
                        case 22:
                           PotionInteraction(4,0);
                           break;
                        case 26:
                           PotionInteraction(6,0);
                           break;
                        case 27:
                           PotionInteraction(7,0);
                           break;
                        case 28:
                           PotionInteraction(5,0);
                           break;
                        case 121:
                           PotionInteraction(10,0);
                           break;
                        case 122:
                           PotionInteraction(11,0);
                           break;
                        case 112:
                           PotionInteraction(8,0);
                           break;
                        case 114:
                           PotionInteraction(9,0);
                     }
                     this.addTextLine.dispatch(ChatMessage.make("","\'" + itemXML.attribute("id") + "\' not consumed. " + "You already maxed this stat."));
                     SoundEffectLibrary.play("error");
                     return false;
                  }
                  if(baseStat + int(itemXML.Activate.@amount) >= stats[2])
                  {
                     consumeResult = "You are now maxed in this stat.";
                  }
                  else
                  {
                     consumeResult = stats[2] - (baseStat + int(itemXML.Activate.@amount)) + " left to max this stat.";
                  }
                  this.addTextLine.dispatch(ChatMessage.make("","\'" + itemXML.attribute("id") + "\' consumed. " + consumeResult));
               }
               this.applyUseItem(go,slot,itemData,itemXML);
               SoundEffectLibrary.play("use_potion");
               return true;
            }
            if(itemXML.hasOwnProperty("Consumable") || itemXML.hasOwnProperty("InvUse"))
            {
               this.applyUseItem(go,slot,itemData,itemXML);
               SoundEffectLibrary.play("use_potion");
               return true;
            }
         }
         SoundEffectLibrary.play("error");
         return false;
      }
      
      private function applyUseItem(go:GameObject, slotId:int, itemData:ItemData, xml:XML) : void
      {
         var useItem:UseItem;
         (useItem = this.messages.require(1) as UseItem).time_ = getTimer();
         useItem.slotObject_.objectId_ = go.objectId;
         useItem.slotObject_.slotId_ = slotId;
         useItem.slotObject_.itemData_ = itemData.toString();
         useItem.itemUsePos_.x_ = 0;
         useItem.itemUsePos_.y_ = 0;
         serverConnection.sendMessage(useItem);
         if(xml.hasOwnProperty("Consumable"))
         {
            go.equipment_[slotId] = new ItemData();
         }
      }
      
      public function setCondition(_arg1:uint, _arg2:Number) : void
      {
         var _local3:SetCondition = this.messages.require(60) as SetCondition;
         _local3.conditionEffect_ = _arg1;
         _local3.conditionDuration_ = _arg2;
         serverConnection.sendMessage(_local3);
      }
      
      public function move(_arg1:int, _arg2:Player) : void
      {
         var _local7:int = 0;
         var _local8:int = 0;
         var _local5:* = null;
         var _local6:int = 0;
         var _local3:* = -1;
         var _local4:* = -1;
         if(_arg2 && !_arg2.isPaused())
         {
            _local3 = Number(_arg2.x_);
            _local4 = Number(_arg2.y_);
         }
         if(_arg1 >= 0)
         {
            (_local5 = this.messages.require(16) as Move).objectId_ = _arg2.objectId;
            _local5.tickId_ = _arg1;
            _local5.time_ = gs.lastUpdate_;
            _local5.newPosition_.x_ = _local3;
            _local5.newPosition_.y_ = _local4;
            _local6 = gs.moveRecords_.lastClearTime_;
            _local5.records_.length = 0;
            if(_local6 >= 0 && _local5.time_ - _local6 > 125)
            {
               _local7 = Math.min(10,gs.moveRecords_.records_.length);
               _local8 = 0;
               while(_local8 < _local7)
               {
                  if(gs.moveRecords_.records_[_local8].time_ >= _local5.time_ - 25)
                  {
                     break;
                  }
                  _local5.records_.push(gs.moveRecords_.records_[_local8]);
                  _local8++;
               }
            }
            gs.moveRecords_.clear(_local5.time_);
            serverConnection.sendMessage(_local5);
         }
         _arg2 && _arg2.onMove();
      }
      
      public function teleport(_arg1:int) : void
      {
         var _local2:Teleport = this.messages.require(45) as Teleport;
         _local2.objectId_ = _arg1;
         serverConnection.sendMessage(_local2);
      }
      
      public function usePortal(_arg1:int) : void
      {
         var _local2:UsePortal = this.messages.require(6) as UsePortal;
         _local2.objectId_ = _arg1;
         serverConnection.sendMessage(_local2);
         this.checkDavyKeyRemoval();
      }
      
      private function checkDavyKeyRemoval() : void
      {
         if(gs.map && gs.map.mapName == "Davy Jones\' Locker")
         {
            ShowHideKeyUISignal.instance.dispatch();
         }
      }
      
      private function onTrialsOpen(_arg1:ShowTrials) : void
      {
         var _local_2:* = null;
         if(_arg1.openDialog)
         {
            _local_2 = StaticInjectorContext.getInjector().getInstance(OpenDialogSignal);
            _local_2.dispatch(new TrialsPanel(gs));
         }
      }
      
      public function buy(sellableObjectId:int, quantity:int) : void
      {
         if(outstandingBuy_)
         {
            return;
         }
         var sObj:SellableObject = gs.map.goDict[sellableObjectId];
         if(sObj == null)
         {
            return;
         }
         if(sObj.soldObjectName() == "Vault.chest")
         {
            this.openDialog.dispatch(new PurchaseConfirmationDialog(function():void
            {
               buyConfirmation(sellableObjectId,quantity);
            }));
         }
         else
         {
            this.buyConfirmation(sellableObjectId,quantity);
         }
      }
      
      public function buyConfirmation(_arg1:int, _arg2:int, _arg3:uint = 0, _arg4:int = 0) : void
      {
         outstandingBuy_ = true;
         var _local5:Buy;
         (_local5 = this.messages.require(93) as Buy).objectId_ = _arg1;
         _local5.quantity_ = _arg2;
         _local5.marketId_ = _arg3;
         _local5.type_ = _arg4;
         serverConnection.sendMessage(_local5);
      }
      
      public function marketGUIBuy(marketId:int, price:int) : void
      {
      }
      
      public function gotoAck(_arg1:int) : void
      {
         var _local2:GotoAck = this.messages.require(79) as GotoAck;
         _local2.time_ = _arg1;
         serverConnection.sendMessage(_local2);
      }
      
      public function editAccountList(_arg1:int, _arg2:Boolean, _arg3:int) : void
      {
         var _local4:EditAccountList;
         (_local4 = this.messages.require(62) as EditAccountList).accountListId_ = _arg1;
         _local4.add_ = _arg2;
         _local4.objectId_ = _arg3;
         serverConnection.sendMessage(_local4);
      }
      
      public function chooseName(_arg1:String) : void
      {
         var _local2:ChooseName = this.messages.require(23) as ChooseName;
         _local2.name_ = _arg1;
         serverConnection.sendMessage(_local2);
      }
      
      public function createGuild(_arg1:String) : void
      {
         var _local2:CreateGuild = this.messages.require(95) as CreateGuild;
         _local2.name_ = _arg1;
         serverConnection.sendMessage(_local2);
      }
      
      public function guildRemove(_arg1:String) : void
      {
         var _local2:GuildRemove = this.messages.require(49) as GuildRemove;
         _local2.name_ = _arg1;
         serverConnection.sendMessage(_local2);
      }
      
      public function guildInvite(_arg1:String) : void
      {
         var _local2:GuildInvite = this.messages.require(41) as GuildInvite;
         _local2.name_ = _arg1;
         serverConnection.sendMessage(_local2);
      }
      
      public function requestTrade(_arg1:String) : void
      {
         var _local2:RequestTrade = this.messages.require(34) as RequestTrade;
         _local2.name_ = _arg1;
         serverConnection.sendMessage(_local2);
      }
      
      public function requestPartyInvite(_arg1:String) : void
      {
         var _local2:RequestPartyInvite = this.messages.require(168) as RequestPartyInvite;
         _local2.name_ = _arg1;
         serverConnection.sendMessage(_local2);
      }
      
      public function requestGamble(_arg1:String, _arg2:int) : void
      {
         var _local2:RequestGamble = this.messages.require(167) as RequestGamble;
         _local2.name_ = _arg1;
         _local2.amount_ = _arg2;
         serverConnection.sendMessage(_local2);
      }
      
      public function acceptPartyInvite(_arg1:String) : void
      {
         var _local2:AcceptPartyInvite = this.messages.require(170) as AcceptPartyInvite;
         _local2.From_ = _arg1;
         serverConnection.sendMessage(_local2);
      }
      
      public function changeTrade(_arg1:Vector.<Boolean>) : void
      {
         var _local2:ChangeTrade = this.messages.require(55) as ChangeTrade;
         _local2.offer_ = _arg1;
         serverConnection.sendMessage(_local2);
      }
      
      public function acceptTrade(_arg1:Vector.<Boolean>, _arg2:Vector.<Boolean>) : void
      {
         var _local3:AcceptTrade = this.messages.require(3) as AcceptTrade;
         _local3.myOffer_ = _arg1;
         _local3.yourOffer_ = _arg2;
         serverConnection.sendMessage(_local3);
      }
      
      public function cancelTrade() : void
      {
         serverConnection.sendMessage(this.messages.require(39));
      }
      
      public function checkCredits() : void
      {
         serverConnection.sendMessage(this.messages.require(20));
      }
      
      public function escape() : void
      {
         if(this.playerId_ == -1)
         {
            return;
         }
         if(gameId_ == -2)
         {
            gs.closed.dispatch();
            return;
         }
         if(gs.map && gs.map.mapName == "Arena")
         {
            serverConnection.sendMessage(this.messages.require(84));
            return;
         }
         this.checkDavyKeyRemoval();
         reconnect2Nexus();
      }
      
      public function gotoQuestRoom() : void
      {
         serverConnection.sendMessage(this.messages.require(155));
      }
      
      public function joinGuild(_arg1:String) : void
      {
         var _local2:JoinGuild = this.messages.require(27) as JoinGuild;
         _local2.guildName_ = _arg1;
         serverConnection.sendMessage(_local2);
      }
      
      public function changeGuildRank(_arg1:String, _arg2:int) : void
      {
         var _local3:ChangeGuildRank = this.messages.require(11) as ChangeGuildRank;
         _local3.name_ = _arg1;
         _local3.guildRank_ = _arg2;
         serverConnection.sendMessage(_local3);
      }
      
      private function rsaEncrypt(_arg1:String) : String
      {
         var _local2:RSAKey = PEM.readRSAPublicKey("-----BEGIN PUBLIC KEY-----\nMFswDQYJKoZIhvcNAQEBBQADSgAwRwJAeyjMOLhcK4o2AnFRhn8vPteUy5Fux/cXN/J+wT/zYIEUINo02frn+Kyxx0RIXJ3CvaHkwmueVL8ytfqo8Ol/OwIDAQAB\n-----END PUBLIC KEY-----");
         var _local3:ByteArray = new ByteArray();
         _local3.writeUTFBytes(_arg1);
         var _local4:ByteArray = new ByteArray();
         _local2.encrypt(_local3,_local4,_local3.length);
         return Base64.encodeByteArray(_local4);
      }
      
      private function onConnected() : void
      {
         var acc:Account = StaticInjectorContext.getInjector().getInstance(Account);
         this.addTextLine.dispatch(ChatMessage.make("*Client*","chat.connected"));
         this.encryptConnection();
         var hello:Hello = this.messages.require(9) as Hello;
         hello.buildVersion = "4.1.1";
         hello.gameId = gameId_;
         hello.guid = this.rsaEncrypt(acc.getUserId());
         hello.loginToken = this.rsaEncrypt(acc.getLoginToken());
         hello.keyTime = keyTime_;
         hello.key.length = 0;
         key_ != null && hello.key.writeBytes(key_);
         hello.mapJSON = mapJSON_ == null ? "" : mapJSON_;
         serverConnection.sendMessage(hello);
      }
      
      private function onCreateSuccess(_arg1:CreateSuccess) : void
      {
         this.playerId_ = _arg1.objectId_;
         charId_ = _arg1.charId_;
         gs.initialize();
         createCharacter_ = false;
      }
      
      private function onDamage(_arg1:Damage) : void
      {
         var _local5:int = 0;
         var _local3:* = null;
         var _local2:AbstractMap = gs.map;
         if(_arg1.objectId_ >= 0 && _arg1.bulletId_ > 0)
         {
            if((_local5 = Projectile.findObjId(_arg1.objectId_,_arg1.bulletId_)) != -1)
            {
               _local3 = _local2.boDict[_local5] as Projectile;
               if(_local3 != null && !_local3.projProps.multiHit)
               {
                  _local2.removeObj(_local5);
               }
            }
         }
         var _local4:GameObject;
         if((_local4 = _local2.goDict[_arg1.targetId_]) != null && !_local4.dead && !(_local4 is Player && _local4.objectId != this.playerId_ && Parameters.data.noAllyDamage))
         {
            _local4.damage(-1,_arg1.damageAmount_,_arg1.effects_,_arg1.kill_,_local3);
         }
      }
      
      private function onServerPlayerShoot(_arg1:ServerPlayerShoot) : void
      {
         var itemData:* = null;
         itemData = null;
         var _local2:* = _arg1.ownerId_ == this.playerId_;
         var _local3:GameObject = gs.map.goDict[_arg1.ownerId_];
         if(_local3 == null || _local3.dead)
         {
            if(_local2)
            {
               this.shootAck(-1);
            }
            return;
         }
         if(_local3.objectId != this.playerId_ && Parameters.data.disableAllyParticles)
         {
            return;
         }
         var _local4:Projectile = FreeList.newObject(Projectile) as Projectile;
         var _local5:Player = _local3 as Player;
         if(_arg1.itemData == "NaN")
         {
            itemData = null;
         }
         else
         {
            itemData = new ItemData(_arg1.itemData);
         }
         if(_local5 != null)
         {
            _local4.reset(_arg1.containerType_,0,_arg1.ownerId_,_arg1.bulletId_,_arg1.angle_,gs.lastUpdate_,_local5.projectileIdSetOverrideNew,_local5.projectileIdSetOverrideOld,itemData);
         }
         else
         {
            _local4.reset(_arg1.containerType_,0,_arg1.ownerId_,_arg1.bulletId_,_arg1.angle_,gs.lastUpdate_,"","",itemData);
         }
         _local4.setDamage(_arg1.damage_);
         gs.map.addObj(_local4,_arg1.startingPos_.x_,_arg1.startingPos_.y_);
         if(_local2)
         {
            this.shootAck(gs.lastUpdate_);
         }
      }
      
      private function onAllyShoot(_arg1:AllyShoot) : void
      {
         var _local2:GameObject = gs.map.goDict[_arg1.ownerId_];
         if(_local2 == null || _local2.dead || Parameters.data.disableAllyParticles)
         {
            return;
         }
         var _local3:Projectile = FreeList.newObject(Projectile) as Projectile;
         var _local4:Player;
         if((_local4 = _local2 as Player) != null)
         {
            _local3.reset(_arg1.containerType_,0,_arg1.ownerId_,_arg1.bulletId_,_arg1.angle_,gs.lastUpdate_,_local4.projectileIdSetOverrideNew,_local4.projectileIdSetOverrideOld);
         }
         else
         {
            _local3.reset(_arg1.containerType_,0,_arg1.ownerId_,_arg1.bulletId_,_arg1.angle_,gs.lastUpdate_);
         }
         gs.map.addObj(_local3,_local2.x_,_local2.y_);
         _local2.setAttack(_arg1.containerType_,_arg1.angle_);
      }
      
      private function onReskinUnlock(_arg1:ReskinUnlock) : void
      {
         var _local3:* = null;
         _local3 = this.classesModel.getCharacterClass(this.model.player.objectType_).skins.getSkin(_arg1.skinID);
         _local3.setState(CharacterSkinState.OWNED);
      }
      
      private function onEnemyShoot(_arg1:EnemyShoot) : void
      {
         var _local4:* = null;
         var _local5:Number = NaN;
         var _local3:int = 0;
         var _local2:GameObject = gs.map.goDict[_arg1.ownerId_];
         if(_local2 == null || _local2.dead)
         {
            this.shootAck(-1);
            return;
         }
         while(_local3 < _arg1.numShots_)
         {
            _local4 = FreeList.newObject(Projectile) as Projectile;
            _local5 = _arg1.angle_ + _arg1.angleInc_ * _local3;
            _local4.reset(_local2.objectType_,_arg1.bulletType_,_arg1.ownerId_,(_arg1.bulletId_ + _local3) % 512,_local5,gs.lastUpdate_);
            _local4.setDamage(_arg1.damage_);
            gs.map.addObj(_local4,_arg1.startingPos_.x_,_arg1.startingPos_.y_);
            _local3++;
         }
         this.shootAck(gs.lastUpdate_);
         _local2.setAttack(_local2.objectType_,_arg1.angle_ + _arg1.angleInc_ * ((_arg1.numShots_ - 1) / 2));
      }
      
      private function onTradeRequested(_arg1:TradeRequested) : void
      {
         if(!Parameters.data.chatTrade)
         {
            return;
         }
         if(Parameters.data.tradeWithFriends)
         {
            return;
         }
         if(Parameters.data.showTradePopup)
         {
            gs.hudView.interactPanel.setOverride(new TradeRequestPanel(gs,_arg1.name_));
         }
         this.addTextLine.dispatch(ChatMessage.make("",_arg1.name_ + " wants to " + "trade with you.  Type \"/trade " + _arg1.name_ + "\" to trade."));
      }
      
      private function onGambleRequest(_arg1:GambleStart) : void
      {
         if(!Parameters.data.chatTrade)
         {
            return;
         }
         if(Parameters.data.tradeWithFriends)
         {
            return;
         }
         if(Parameters.data.showTradePopup)
         {
            gs.hudView.interactPanel.setOverride(new GambleRequestPanel(gs,_arg1.name_,_arg1.amount_));
         }
         this.addTextLine.dispatch(ChatMessage.make("",_arg1.name_ + " wants to " + "gamble with you."));
      }
      
      private function onPartyInviteRequest(_arg1:PartyRequest) : void
      {
         if(!Parameters.data.chatTrade)
         {
            return;
         }
         if(Parameters.data.tradeWithFriends)
         {
            return;
         }
         if(Parameters.data.showTradePopup)
         {
            gs.hudView.interactPanel.setOverride(new PartyInvitePanel(gs,_arg1.from_,_arg1.name_));
         }
      }
      
      private function onTradeStart(_arg1:TradeStart) : void
      {
         gs.hudView.startTrade(gs,_arg1);
      }
      
      private function onTradeChanged(_arg1:TradeChanged) : void
      {
         gs.hudView.tradeChanged(_arg1);
      }
      
      private function onTradeDone(_arg1:TradeDone) : void
      {
         var _local3:* = null;
         var _local4:* = null;
         gs.hudView.tradeDone();
         var _local2:String = "";
         try
         {
            _local2 = (_local4 = JSON.parse(_arg1.description_)).key;
            _local3 = _local4.tokens;
         }
         catch(e:Error)
         {
         }
         this.addTextLine.dispatch(ChatMessage.make("",_local2,-1,-1,"",false,_local3));
      }
      
      private function onTradeAccepted(_arg1:TradeAccepted) : void
      {
         gs.hudView.tradeAccepted(_arg1);
      }
      
      private function addObject(_arg1:ObjectData) : void
      {
         var _local2:AbstractMap = gs.map;
         var _local3:GameObject = ObjectLibrary.getObjectFromType(_arg1.objectType_);
         if(_local3 == null)
         {
            return;
         }
         var _local4:ObjectStatusData = _arg1.status_;
         _local3.setObjectId(_local4.objectId_);
         _local2.addObj(_local3,_local4.pos_.x_,_local4.pos_.y_);
         if(_local3 is Player)
         {
            this.handleNewPlayer(_local3 as Player,_local2);
         }
         this.processObjectStatus(_local4,0,-1);
         if(_local3.props.static_ && _local3.props.occupySquare_ && !_local3.props.noMiniMap_)
         {
            this.updateGameObjectTileSignal.dispatch(new UpdateGameObjectTileVO(_local3.x_,_local3.y_,_local3));
         }
      }
      
      private function handleNewPlayer(_arg1:Player, _arg2:AbstractMap) : void
      {
         this.setPlayerSkinTemplate(_arg1,0);
         if(_arg1.objectId == this.playerId_)
         {
            this.player = _arg1;
            this.model.player = _arg1;
            _arg2.player = _arg1;
            gs.setFocus(_arg1);
            this.setGameFocus.dispatch(this.playerId_.toString());
         }
      }
      
      private function onUpdate(update:Update) : void
      {
         var index:int = 0;
         var tileData:* = null;
         var updateAck:Message = this.messages.require(91);
         serverConnection.sendMessage(updateAck);
         index = 0;
         while(index < update.tiles.length)
         {
            tileData = update.tiles[index];
            gs.map.setGroundTile(tileData.x_,tileData.y_,tileData.type_);
            this.updateGroundTileSignal.dispatch(new UpdateGroundTileVO(tileData.x_,tileData.y_,tileData.type_));
            index++;
         }
         index = 0;
         while(index < update.drops.length)
         {
            gs.map.removeObj(update.drops[index]);
            index++;
         }
         index = 0;
         while(index < update.newObjs.length)
         {
            this.addObject(update.newObjs[index]);
            index++;
         }
      }
      
      private function onNotification(notif:Notification) : void
      {
         var lineBuilder:LineBuilder = null;
         var go:GameObject = gs.map.goDict[notif.objectId_];
         if(go != null)
         {
            lineBuilder = LineBuilder.fromJSON(notif.message);
            if(go == this.player)
            {
               if(lineBuilder.key == "server.quest_complete")
               {
                  gs.map.quest.completed();
               }
               this.makeNotification(lineBuilder,go,notif.color_,1000);
            }
            else if(go.props.isEnemy || !Parameters.data.noAllyNotifications)
            {
               this.makeNotification(lineBuilder,go,notif.color_,1000);
            }
         }
      }
      
      private function makeNotification(lineBuilder:LineBuilder, go:GameObject, color:uint, lifetime:int) : void
      {
         var statusText:CharacterStatusText;
         (statusText = new CharacterStatusText(go,color,lifetime)).setStringBuilder(lineBuilder);
         gs.map.mapOverlay.addStatusText(statusText);
      }
      
      private function onGlobalNotification(_arg1:GlobalNotification) : void
      {
         switch(_arg1.text)
         {
            case "yellow":
               ShowKeySignal.instance.dispatch(Key.YELLOW);
               return;
            case "red":
               ShowKeySignal.instance.dispatch(Key.RED);
               return;
            case "green":
               ShowKeySignal.instance.dispatch(Key.GREEN);
               return;
            case "purple":
               ShowKeySignal.instance.dispatch(Key.PURPLE);
               return;
            case "showKeyUI":
               ShowHideKeyUISignal.instance.dispatch();
               return;
            case "giftChestOccupied":
               this.giftChestUpdateSignal.dispatch(true);
               return;
            case "giftChestEmpty":
               this.giftChestUpdateSignal.dispatch(false);
               return;
            case "beginnersPackage":
               return;
            default:
               return;
         }
      }
      
      private function onNewTick(_arg1:NewTick) : void
      {
         var _local2:* = null;
         if(jitterWatcher_ != null)
         {
            jitterWatcher_.record();
         }
         this.move(_arg1.tickId_,this.player);
         for each(_local2 in _arg1.statuses_)
         {
            this.processObjectStatus(_local2,_arg1.tickTime_,_arg1.tickId_);
         }
         lastTickId_ = _arg1.tickId_;
      }
      
      private function canShowEffect(go:GameObject) : Boolean
      {
         if(go != null)
         {
            return true;
         }
         var isPlayer:* = go.objectId == this.playerId_;
         return !isPlayer && go.props.isPlayer && Parameters.data.disableAllyParticles;
      }
      
      private function onShowEffect(se:ShowEffect) : void
      {
         var go:* = null;
         var particleEffect:* = null;
         var toPos:* = null;
         var time:* = 0;
         var map:AbstractMap = gs.map;
         if(Parameters.data.noParticlesMaster && (se.effectType_ == 1 || se.effectType_ == 2 || se.effectType_ == 3 || se.effectType_ == 6 || se.effectType_ == 7 || se.effectType_ == 9 || se.effectType_ == 12 || se.effectType_ == 13))
         {
            return;
         }
         switch(int(se.effectType_) - 1)
         {
            case 0:
               go = map.goDict[se.targetObjectId_];
               if(!(go == null || !this.canShowEffect(go)))
               {
                  map.addObj(new HealEffect(go,se.color_),go.x_,go.y_);
                  return;
               }
               break;
            case 3:
               go = map.goDict[se.targetObjectId_];
               if(!(go == null || !this.canShowEffect(go)))
               {
                  toPos = go != null ? new Point(go.x_,go.y_) : se.pos2_.toPoint();
                  particleEffect = new ThrowEffect(toPos,se.pos1_.toPoint(),se.color_,se.duration_ * 1000);
                  map.addObj(particleEffect,toPos.x,toPos.y);
                  return;
               }
               break;
            case 4:
               go = map.goDict[se.targetObjectId_];
               if(!(go == null || !this.canShowEffect(go)))
               {
                  particleEffect = new NovaEffect(go,se.pos1_.x_,se.color_);
                  map.addObj(particleEffect,go.x_,go.y_);
                  return;
               }
               break;
            case 5:
               go = map.goDict[se.targetObjectId_];
               if(!(go == null || !this.canShowEffect(go)))
               {
                  particleEffect = new PoisonEffect(go,se.color_);
                  map.addObj(particleEffect,go.x_,go.y_);
                  return;
               }
               break;
            case 6:
               go = map.goDict[se.targetObjectId_];
               if(!(go == null || !this.canShowEffect(go)))
               {
                  particleEffect = new LineEffect(go,se.pos1_,se.color_);
                  map.addObj(particleEffect,se.pos1_.x_,se.pos1_.y_);
                  return;
               }
               break;
            case 7:
               go = map.goDict[se.targetObjectId_];
               if(!(go == null || !this.canShowEffect(go)))
               {
                  particleEffect = new BurstEffect(go,se.pos1_,se.pos2_,se.color_);
                  map.addObj(particleEffect,se.pos1_.x_,se.pos1_.y_);
                  return;
               }
               break;
            case 8:
               go = map.goDict[se.targetObjectId_];
               if(!(go == null || !this.canShowEffect(go)))
               {
                  particleEffect = new FlowEffect(se.pos1_,go,se.color_);
                  map.addObj(particleEffect,se.pos1_.x_,se.pos1_.y_);
                  return;
               }
               break;
            case 9:
               go = map.goDict[se.targetObjectId_];
               if(!(go == null || !this.canShowEffect(go)))
               {
                  particleEffect = new RingEffect(go,se.pos1_.x_,se.color_);
                  map.addObj(particleEffect,go.x_,go.y_);
                  return;
               }
               break;
            case 10:
               go = map.goDict[se.targetObjectId_];
               if(!(go == null || !this.canShowEffect(go)))
               {
                  particleEffect = new LightningEffect(go,se.pos1_,se.color_,se.pos2_.x_);
                  map.addObj(particleEffect,go.x_,go.y_);
                  return;
               }
               break;
            case 11:
               go = map.goDict[se.targetObjectId_];
               if(!(go == null || !this.canShowEffect(go)))
               {
                  particleEffect = new CollapseEffect(go,se.pos1_,se.pos2_,se.color_);
                  map.addObj(particleEffect,se.pos1_.x_,se.pos1_.y_);
                  return;
               }
               break;
            case 12:
               go = map.goDict[se.targetObjectId_];
               if(!(go == null || !this.canShowEffect(go)))
               {
                  particleEffect = new ConeBlastEffect(go,se.pos1_,se.pos2_.x_,se.color_);
                  map.addObj(particleEffect,go.x_,go.y_);
                  return;
               }
               break;
            case 14:
               go = map.goDict[se.targetObjectId_];
               if(!(go == null || !this.canShowEffect(go)))
               {
                  go.flash = new FlashDescription(getTimer(),se.color_,se.pos1_.x_,se.pos1_.y_);
                  return;
               }
               break;
            case 15:
               toPos = se.pos1_.toPoint();
               if(!(go == null || !this.canShowEffect(go)))
               {
                  particleEffect = new ThrowProjectileEffect(se.color_,se.pos2_.toPoint(),se.pos1_.toPoint());
                  map.addObj(particleEffect,toPos.x,toPos.y);
                  return;
               }
               break;
            case 16:
               go = map.goDict[se.targetObjectId_];
               if(!(go == null || !this.canShowEffect(go)))
               {
                  if(go && go.shockEffect)
                  {
                     go.shockEffect.destroy();
                  }
                  particleEffect = new ShockerEffect(go);
                  go.shockEffect = ShockerEffect(particleEffect);
                  gs.map.addObj(particleEffect,go.x_,go.y_);
                  return;
               }
               break;
            case 17:
               go = map.goDict[se.targetObjectId_];
               if(!(go == null || !this.canShowEffect(go)))
               {
                  particleEffect = new ShockeeEffect(go);
                  gs.map.addObj(particleEffect,go.x_,go.y_);
                  return;
               }
               break;
            case 18:
               go = map.goDict[se.targetObjectId_];
               if(!(go == null || !this.canShowEffect(go)))
               {
                  time = uint(se.pos1_.x_ * 1000);
                  particleEffect = new RisingFuryEffect(go,time);
                  gs.map.addObj(particleEffect,go.x_,go.y_);
                  return;
               }
               break;
            default:
               break;
            case 1:
               map.addObj(new TeleportEffect(),se.pos1_.x_,se.pos1_.y_);
               return;
            case 2:
               particleEffect = new StreamEffect(se.pos1_,se.pos2_,se.color_);
               map.addObj(particleEffect,se.pos1_.x_,se.pos1_.y_);
               return;
            case 13:
               gs.camera_.startJitter();
               return;
         }
      }
      
      private function onGoto(_arg1:Goto) : void
      {
         this.gotoAck(gs.lastUpdate_);
         var _local2:GameObject = gs.map.goDict[_arg1.objectId_];
         if(_local2 == null)
         {
            return;
         }
         _local2.onGoto(_arg1.pos_.x_,_arg1.pos_.y_,gs.lastUpdate_);
      }
      
      private function updateGameObject(go:GameObject, statDataVec:Vector.<StatData>, isLocalObj:Boolean) : void
      {
         var statData:* = null;
         var statValue:int = 0;
         var invIndex:int = 0;
         var bpIndex:int = 0;
         var respriteData:* = null;
         var player:Player = go as Player;
         var merchant:Merchant = go as Merchant;
         for each(statData in statDataVec)
         {
            statValue = statData.statValue_;
            switch(statData.statType_)
            {
               case 0:
                  go.maxHP_ = statValue;
                  continue;
               case 1:
                  go.hp_ = statValue;
                  continue;
               case 2:
                  go.setSize(statValue);
                  continue;
               case 3:
                  player.maxMP_ = statValue;
                  continue;
               case 4:
                  player.mp_ = statValue;
                  continue;
               case 5:
                  player.nextLevelExp_ = statValue;
                  continue;
               case 6:
                  player.exp_ = statValue;
                  continue;
               case 7:
                  go.level_ = statValue;
                  continue;
               case 20:
                  player.attack_ = statValue;
                  continue;
               case 21:
                  go.defense_ = statValue;
                  continue;
               case 22:
                  player.speed_ = statValue;
                  continue;
               case 28:
                  player.dexterity_ = statValue;
                  continue;
               case 26:
                  player.vitality_ = statValue;
                  continue;
               case 27:
                  player.wisdom_ = statValue;
                  continue;
               case 29:
                  go.condition_[0] = statValue;
                  continue;
               case 8:
               case 9:
               case 10:
               case 11:
               case 12:
               case 13:
               case 14:
               case 15:
               case 16:
               case 17:
               case 18:
                  break;
               case 19:
                  break;
               case 30:
                  player.numStars_ = statValue;
                  continue;
               case 31:
                  if(go.name_ != statData.strStatValue_)
                  {
                     go.name_ = statData.strStatValue_;
                     go.nameBitmapData_ = null;
                  }
                  continue;
               case 32:
                  if(statValue >= 0)
                  {
                     go.setTex1(statValue);
                  }
                  continue;
               case 33:
                  if(statValue >= 0)
                  {
                     go.setTex2(statValue);
                  }
                  continue;
               case 34:
                  merchant.setMerchandiseType(new ItemData(statData.strStatValue_));
                  continue;
               case 35:
                  player.setCredits(statValue);
                  continue;
               case 36:
                  (go as SellableObject).setPrice(statValue);
                  continue;
               case 37:
                  continue;
               case 38:
                  player.accountId_ = statData.strStatValue_;
                  continue;
               case 39:
                  player.fame_ = statValue;
                  continue;
               case 97:
                  player.setTokens(statValue);
                  continue;
               case 40:
                  (go as SellableObject).setCurrency(statValue);
                  continue;
               case 41:
                  go.connectType_ = statValue;
                  continue;
               case 42:
                  merchant.count_ = statValue;
                  merchant.untilNextMessage_ = 0;
                  continue;
               case 43:
                  merchant.minsLeft_ = statValue;
                  merchant.untilNextMessage_ = 0;
                  continue;
               case 44:
                  merchant.discount_ = statValue;
                  merchant.untilNextMessage_ = 0;
                  continue;
               case 45:
                  (go as SellableObject).setRankReq(statValue);
                  continue;
               case 46:
                  player.maxHPBoost_ = statValue;
                  continue;
               case 47:
                  player.maxMPBoost_ = statValue;
                  continue;
               case 48:
                  player.attackBoost_ = statValue;
                  continue;
               case 49:
                  player.defenseBoost_ = statValue;
                  continue;
               case 50:
                  player.speedBoost_ = statValue;
                  continue;
               case 51:
                  player.vitalityBoost_ = statValue;
                  continue;
               case 52:
                  player.wisdomBoost_ = statValue;
                  continue;
               case 53:
                  player.dexterityBoost_ = statValue;
                  continue;
               case 54:
                  if(go is Friend)
                  {
                     (go as Friend).accOwnerId = statData.strStatValue_;
                     return;
                  }
                  if(go is Container)
                  {
                     (go as Container).setOwnerId(statData.strStatValue_);
                  }
                  continue;
               case 55:
                  (go as NameChanger).setRankRequired(statValue);
                  continue;
               case 56:
                  player.nameChosen_ = statValue != 0;
                  go.nameBitmapData_ = null;
                  continue;
               case 57:
                  player.currFame_ = statValue;
                  continue;
               case 58:
                  player.nextClassQuestFame_ = statValue;
                  continue;
               case 59:
                  player.setGlow(statValue);
                  continue;
               case 60:
                  if(!isLocalObj)
                  {
                     player.sinkLevel = statValue;
                  }
                  continue;
               case 61:
                  go.setAltTexture(statValue);
                  continue;
               case 62:
                  player.setGuildName(statData.strStatValue_);
                  continue;
               case 63:
                  player.guildRank_ = statValue;
                  continue;
               case 65:
                  player.xpBoost_ = statValue;
                  continue;
               case 66:
                  player.xpTimer = statValue * 1000;
                  continue;
               case 67:
                  player.dropBoost = statValue * 1000;
                  continue;
               case 68:
                  player.tierBoost = statValue * 1000;
                  continue;
               case 69:
                  player.healthPotionCount_ = statValue;
                  continue;
               case 70:
                  player.magicPotionCount_ = statValue;
                  continue;
               case 80:
                  if(player.skinId != statValue && statValue >= 0)
                  {
                     this.setPlayerSkinTemplate(player,statValue);
                  }
                  continue;
               case 79:
                  (go as Player).hasBackpack_ = Boolean(statValue);
                  if(isLocalObj)
                  {
                     this.updateBackpackTab.dispatch(Boolean(statValue));
                  }
                  continue;
               case 71:
               case 72:
               case 73:
               case 74:
               case 75:
               case 76:
               case 77:
               case 78:
                  bpIndex = statData.statType_ - 71 + 4 + 8;
                  if((go as Player).equipment_.length <= bpIndex)
                  {
                     (go as Player).equipment_.length = bpIndex + 1;
                  }
                  (go as Player).equipment_[bpIndex] = new ItemData(statData.strStatValue_);
                  continue;
               case 96:
                  go.condition_[1] = statValue;
                  continue;
               case 109:
                  player.raidRank_ = statValue;
                  continue;
               case 103:
                  player.rank_ = statValue;
                  continue;
               case 104:
                  player.admin_ = statValue == 1;
                  continue;
               case 106:
                  player.setOnrane(statValue);
                  continue;
               case 107:
                  player.setKantos(statValue);
                  continue;
               case 108:
                  player.alertToken_ = statValue;
                  continue;
               case 110:
                  player.surge_ = statValue;
                  continue;
               case 112:
                  player.might_ = statValue;
                  continue;
               case 114:
                  player.luck_ = statValue;
                  continue;
               case 113:
                  player.mightBoost_ = statValue;
                  continue;
               case 115:
                  player.luckBoost_ = statValue;
                  continue;
               case 116:
                  player.setBronzeLootbox(statValue);
                  continue;
               case 117:
                  player.setSilverLootbox(statValue);
                  continue;
               case 118:
                  player.setGoldLootbox(statValue);
                  continue;
               case 119:
                  player.setEliteLootbox(statValue);
                  continue;
               case 120:
                  player.premiumLootbox_ = statValue;
                  continue;
               case 235:
                  player.setTrialLootbox(statValue);
                  continue;
               case 121:
                  player.restoration_ = statValue;
                  continue;
               case 122:
                  player.protection_ = statValue;
                  continue;
               case 123:
                  player.restorationBoost_ = statValue;
                  continue;
               case 124:
                  player.protectionBoost_ = statValue;
                  continue;
               case 125:
                  player.protectionPoints_ = statValue;
                  continue;
               case 126:
                  player.protectionPointsMax_ = statValue;
                  continue;
               case 127:
                  player.setEffect(statData.strStatValue_);
                  continue;
               case 128:
                  player.marksEnabled_ = statValue == 1;
                  if(isLocalObj)
                  {
                     this.updateMarkTab.dispatch(Boolean(statValue));
                  }
                  continue;
               case 146:
                  player.ascended = statValue == 1;
                  continue;
               case 129:
                  player.mark_ = statValue;
                  continue;
               case 152:
                  player.storedPotions_ = statValue;
                  continue;
               case 130:
                  player.node1_ = statValue;
                  continue;
               case 131:
                  player.node2_ = statValue;
                  continue;
               case 132:
                  player.node3_ = statValue;
                  continue;
               case 133:
                  player.node4_ = statValue;
                  continue;
               case 147:
                  player.rage_ = statValue;
                  continue;
               case 148:
                  player.sorStorage_ = statValue;
                  continue;
               case 150:
                  player.elite_ = statValue;
                  continue;
               case 151:
                  player.pvp_ = statValue == 1;
                  continue;
               case 155:
                  player.trialTokens_ = statValue;
                  continue;
               case 156:
                  player.mythQuest_ = statValue;
                  continue;
               case 234:
                  player.christmasPresents_ = statValue;
                  continue;
               case 204:
                  player.aspect = statValue;
                  continue;
               case 157:
                  player.mythQuestTrack_ = statValue;
                  continue;
               case 210:
                  player.SPS_Life = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 211:
                  player.SPS_Life_Max = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 212:
                  player.SPS_Mana = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 213:
                  player.SPS_Mana_Max = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 214:
                  player.SPS_Defense = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 215:
                  player.SPS_Defense_Max = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 216:
                  player.SPS_Attack = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 217:
                  player.SPS_Attack_Max = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 218:
                  player.SPS_Dexterity = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 219:
                  player.SPS_Dexterity_Max = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 220:
                  player.SPS_Speed = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 221:
                  player.SPS_Speed_Max = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 222:
                  player.SPS_Vitality = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 223:
                  player.SPS_Vitality_Max = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 224:
                  player.SPS_Wisdom = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 225:
                  player.SPS_Wisdom_Max = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 226:
                  player.SPS_Might = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 227:
                  player.SPS_Might_Max = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 228:
                  player.SPS_Luck = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 229:
                  player.SPS_Luck_Max = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 230:
                  player.SPS_Restoration = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 231:
                  player.SPS_Restoration_Max = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 232:
                  player.SPS_Protection = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 233:
                  player.SPS_Protection_Max = statValue;
                  if(player.SPS_Modal != null)
                  {
                     player.SPS_Modal.draw();
                  }
                  continue;
               case 205:
                  go.condition_[2] = statValue;
                  continue;
               case 81:
                  if(player != this.player)
                  {
                     return;
                  }
                  petId = statValue;
                  continue;
               case 23:
                  if(player != this.player)
                  {
                     return;
                  }
                  BattlePassModel.level = statValue;
                  if(BattlePassModel.isOpened)
                  {
                     BattlePassModel.battlePassTabNeedsUpdate = true;
                  }
                  continue;
               case 24:
                  if(player != this.player)
                  {
                     return;
                  }
                  BattlePassModel.currExp = statValue;
                  if(BattlePassModel.isOpened)
                  {
                     BattlePassModel.battlePassTabNeedsUpdate = true;
                  }
                  continue;
               case 25:
                  if(player != this.player)
                  {
                     return;
                  }
                  BattlePassModel.claimed = statData.strStatValue_;
                  if(BattlePassModel.isOpened)
                  {
                     BattlePassModel.battlePassTabNeedsUpdate = true;
                  }
                  continue;
               case 64:
                  if(player != this.player)
                  {
                     return;
                  }
                  BattlePassModel.premium = statValue != 0;
                  if(BattlePassModel.isOpened)
                  {
                     BattlePassModel.battlePassTabNeedsUpdate = true;
                  }
                  continue;
               case 82:
                  if(statValue != -1 && BattlePassModel.respritesData[statValue] != null)
                  {
                     if((respriteData = BattlePassModel.respritesData[statValue]).specialAnimatedCharTexture != null)
                     {
                        go.animatedChar_ = respriteData.specialAnimatedCharTexture;
                     }
                     if(respriteData.specialTexture != null)
                     {
                        go.texture_ = respriteData.specialTexture;
                     }
                  }
                  continue;
               case 83:
                  player.starIconType = statValue;
                  continue;
               default:
                  continue;
            }
            invIndex = statData.statType_ - 8;
            go.equipment_[invIndex] = new ItemData(statData.strStatValue_);
            if(go is Container)
            {
               (go as Container).isChanged = true;
            }
         }
      }
      
      private function setPlayerSkinTemplate(_arg1:Player, _arg2:int) : void
      {
         var _local3:Reskin = this.messages.require(15) as Reskin;
         _local3.skinID = _arg2;
         _local3.player = _arg1;
         _local3.consume();
      }
      
      private function processObjectStatus(_arg1:ObjectStatusData, _arg2:int, _arg3:int) : void
      {
         var _local8:int = 0;
         var _local9:int = 0;
         var _local10:int = 0;
         var _local11:* = null;
         var _local12:* = null;
         var _local13:* = null;
         var _local14:* = null;
         var _local15:int = 0;
         var _local16:* = null;
         var _local17:* = null;
         var _local18:* = null;
         var _local5:GameObject;
         var _local4:AbstractMap;
         if((_local5 = (_local4 = gs.map).goDict[_arg1.objectId_]) == null)
         {
            return;
         }
         var _local6:* = _arg1.objectId_ == this.playerId_;
         if(_arg2 != 0 && !_local6)
         {
            _local5.onTickPos(_arg1.pos_.x_,_arg1.pos_.y_,_arg2,_arg3);
         }
         var _local7:Player;
         if((_local7 = _local5 as Player) != null)
         {
            _local8 = _local7.level_;
            _local9 = _local7.exp_;
            _local10 = _local7.skinId;
         }
         this.updateGameObject(_local5,_arg1.stats_,_local6);
         if(_local7)
         {
            if(_local6)
            {
               if((_local11 = this.classesModel.getCharacterClass(_local7.objectType_)).getMaxLevelAchieved() < _local7.level_)
               {
                  _local11.setMaxLevelAchieved(_local7.level_);
               }
            }
            if(_local7.skinId != _local10)
            {
               if(ObjectLibrary.skinSetXMLDataLibrary_[_local7.skinId] != null)
               {
                  _local13 = (_local12 = ObjectLibrary.skinSetXMLDataLibrary_[_local7.skinId] as XML).attribute("color");
                  _local14 = _local12.attribute("bulletType");
                  if(_local8 != -1 && _local13.length > 0)
                  {
                     _local7.levelUpParticleEffect(uint(_local13));
                  }
                  if(_local14.length > 0)
                  {
                     _local7.projectileIdSetOverrideNew = _local14;
                     _local15 = _local7.equipment_[0].objectType;
                     _local16 = ObjectLibrary.propsLibrary_[_local15];
                     try
                     {
                        _local17 = _local16.projectiles_[0];
                        _local7.projectileIdSetOverrideOld = _local17.objectId_;
                     }
                     catch(ex:Error)
                     {
                     }
                  }
               }
               else if(ObjectLibrary.skinSetXMLDataLibrary_[_local7.skinId] == null)
               {
                  _local7.projectileIdSetOverrideNew = "";
                  _local7.projectileIdSetOverrideOld = "";
               }
            }
            if(_local8 != -1 && _local7.level_ > _local8)
            {
               if(_local6)
               {
                  _local18 = gs.model.getNewUnlocks(_local7.objectType_,_local7.level_);
                  _local7.handleLevelUp(_local18.length != 0);
               }
               else if(!Parameters.data.noAllyNotifications)
               {
                  _local7.levelUpEffect("Player.levelUp");
               }
            }
            else if(_local8 != -1 && _local7.exp_ > _local9 && (_local6 || !Parameters.data.noAllyNotifications))
            {
               _local7.handleExpUp(_local7.exp_ - _local9);
            }
         }
      }
      
      private function onInvResult(_arg1:InvResult) : void
      {
         if(_arg1.result_ != 0)
         {
            this.handleInvFailure();
         }
      }
      
      private function handleInvFailure() : void
      {
         SoundEffectLibrary.play("error");
         gs.hudView.interactPanel.redraw();
      }
      
      private function onReconnect(_arg1:Reconnect) : void
      {
         var _local2:Server = new Server().setName(_arg1.name_).setAddress(_arg1.host_ != "" ? _arg1.host_ : server_.address).setPort(_arg1.host_ != "" ? _arg1.port_ : int(server_.port));
         var _local3:int = _arg1.gameId_;
         var _local4:Boolean = createCharacter_;
         var _local5:int = charId_;
         var _local6:int = _arg1.keyTime_;
         var _local7:ByteArray = _arg1.key_;
         isFromArena_ = _arg1.isFromArena_;
         var _local8:ReconnectEvent = new ReconnectEvent(_local2,_local3,_local4,_local5,_local6,_local7,isFromArena_);
         gs.dispatchEvent(_local8);
      }
      
      private function reconnect2Nexus() : void
      {
         var svr:Server = new Server().setName("Nexus").setAddress(server_.address).setPort(server_.port);
         var reconEvt:ReconnectEvent = new ReconnectEvent(svr,-2,false,charId_,0,null,isFromArena_);
         gs.dispatchEvent(reconEvt);
      }
      
      private function onPing(_arg1:Ping) : void
      {
         var _local2:Pong = this.messages.require(64) as Pong;
         _local2.serial_ = _arg1.serial_;
         _local2.time_ = getTimer();
         serverConnection.sendMessage(_local2);
      }
      
      private function parseXML(_arg1:String) : void
      {
         var _local2:XML = XML(_arg1);
         GroundLibrary.parseFromXML(_local2);
         ObjectLibrary.parseFromXML(_local2);
      }
      
      private function onMapInfo(_arg1:MapInfo) : void
      {
         var _local2:* = null;
         var _local3:* = null;
         for each(_local2 in _arg1.clientXML_)
         {
            this.parseXML(_local2);
         }
         for each(_local3 in _arg1.extraXML_)
         {
            this.parseXML(_local3);
         }
         changeMapSignal.dispatch();
         this.closeDialogs.dispatch();
         gs.applyMapInfo(_arg1);
         this.rand_ = new Random(_arg1.fp_);
         Music.load(_arg1.music);
         if(createCharacter_)
         {
            this.create();
         }
         else
         {
            this.load();
         }
      }
      
      private function onPic(_arg1:Pic) : void
      {
         gs.addChild(new PicView(_arg1.bitmapData_));
      }
      
      private function onDeath(_arg1:Death) : void
      {
         this.death = _arg1;
         var _local2:BitmapData = new BitmapDataSpy(gs.stage.stageWidth,gs.stage.stageHeight);
         _local2.draw(gs);
         _arg1.background = _local2;
         if(!gs.isEditor)
         {
            this.handleDeath.dispatch(_arg1);
         }
         this.checkDavyKeyRemoval();
      }
      
      private function onBuyResult(_arg1:BuyResult) : void
      {
         outstandingBuy_ = false;
         this.handleBuyResultType(_arg1);
      }
      
      private function handleBuyResultType(_arg1:BuyResult) : void
      {
         var _local2:* = null;
         switch(int(_arg1.result_) - -1)
         {
            case 0:
               _local2 = ChatMessage.make("",_arg1.resultString_);
               this.addTextLine.dispatch(_local2);
               return;
            case 4:
               this.openDialog.dispatch(new NotEnoughGoldDialog());
               return;
            case 7:
               this.openDialog.dispatch(new NotEnoughFameDialog());
               return;
            default:
               this.handleDefaultResult(_arg1);
               return;
         }
      }
      
      private function handleDefaultResult(_arg1:BuyResult) : void
      {
         var _local2:LineBuilder = LineBuilder.fromJSON(_arg1.resultString_);
         var _local3:Boolean = _arg1.result_ == 0 || _arg1.result_ == 7;
         var _local4:ChatMessage;
         (_local4 = ChatMessage.make(!!_local3 ? "" : "*Error*",_local2.key)).tokens = _local2.tokens;
         this.addTextLine.dispatch(_local4);
      }
      
      private function onAccountList(_arg1:AccountList) : void
      {
         if(_arg1.accountListId_ == 0)
         {
            if(_arg1.lockAction_ != -1)
            {
               if(_arg1.lockAction_ == 1)
               {
                  gs.map.party.setStars(_arg1);
               }
               else
               {
                  gs.map.party.removeStars(_arg1);
               }
            }
            else
            {
               gs.map.party.setStars(_arg1);
            }
         }
         else if(_arg1.accountListId_ == 1)
         {
            gs.map.party.setIgnores(_arg1);
         }
      }
      
      private function onQuestObjId(_arg1:QuestObjId) : void
      {
         gs.map.quest.setObject(_arg1.objectId_);
      }
      
      private function onAoe(_arg1:Aoe) : void
      {
         var _local4:int = 0;
         var _local5:* = undefined;
         if(this.player == null)
         {
            this.aoeAck(gs.lastUpdate_,0,0);
            return;
         }
         var _local2:AOEEffect = new AOEEffect(_arg1.pos_.toPoint(),_arg1.radius_,16711680);
         gs.map.addObj(_local2,_arg1.pos_.x_,_arg1.pos_.y_);
         if(this.player.isInvincible() || this.player.isPaused())
         {
            this.aoeAck(gs.lastUpdate_,this.player.x_,this.player.y_);
            return;
         }
         var _local3:* = this.player.distTo(_arg1.pos_) < _arg1.radius_;
         if(_local3)
         {
            _local4 = GameObject.damageWithDefense(_arg1.damage_,this.player.defense_,false,this.player.condition_);
            _local5 = null;
            if(_arg1.effect_ != 0)
            {
               (_local5 = new Vector.<uint>()).push(_arg1.effect_);
            }
            this.player.damage(_arg1.origType_,_local4,_local5,false,null);
         }
         this.aoeAck(gs.lastUpdate_,this.player.x_,this.player.y_);
      }
      
      private function onNameResult(_arg1:NameResult) : void
      {
         gs.dispatchEvent(new NameResultEvent(_arg1));
      }
      
      private function onGuildResult(_arg1:GuildResult) : void
      {
         var _local2:* = null;
         if(_arg1.lineBuilderJSON == "")
         {
            gs.dispatchEvent(new GuildResultEvent(_arg1.success_,"",{}));
         }
         else
         {
            _local2 = LineBuilder.fromJSON(_arg1.lineBuilderJSON);
            this.addTextLine.dispatch(ChatMessage.make("*Error*",_local2.key,-1,-1,"",false,_local2.tokens));
            gs.dispatchEvent(new GuildResultEvent(_arg1.success_,_local2.key,_local2.tokens));
         }
      }
      
      private function onClientStat(_arg1:ClientStat) : void
      {
         var _local2:Account = StaticInjectorContext.getInjector().getInstance(Account);
         _local2.reportIntStat(_arg1.name_,_arg1.value_);
      }
      
      private function onFile(_arg1:File) : void
      {
         new FileReference().save(_arg1.file_,_arg1.filename_);
      }
      
      private function onInvitedToGuild(_arg1:InvitedToGuild) : void
      {
         if(Parameters.data.showGuildInvitePopup)
         {
            gs.hudView.interactPanel.setOverride(new GuildInvitePanel(gs,_arg1.name_,_arg1.guildName_));
         }
         this.addTextLine.dispatch(ChatMessage.make("","You have been invited by " + _arg1.name_ + " to join the guild " + _arg1.guildName_ + ".\n  If you wish to join type \"/join " + _arg1.guildName_ + "\""));
      }
      
      private function onPlaySound(_arg1:PlaySound) : void
      {
         var _local2:GameObject = gs.map.goDict[_arg1.ownerId_];
         _local2 && _local2.playSound(_arg1.soundId_);
      }
      
      private function onImminentArenaWave(_arg1:ImminentArenaWave) : void
      {
         this.imminentWave.dispatch(_arg1.currentRuntime);
      }
      
      private function onArenaDeath(_arg1:ArenaDeath) : void
      {
         this.currentArenaRun.costOfContinue = _arg1.cost;
         this.openDialog.dispatch(new ContinueOrQuitDialog(_arg1.cost,false));
         this.arenaDeath.dispatch();
      }
      
      private function onVerifyEmail(_arg1:VerifyEmail) : void
      {
         TitleView.queueEmailConfirmation = true;
         if(gs != null)
         {
            gs.closed.dispatch();
         }
         var _local2:HideMapLoadingSignal = StaticInjectorContext.getInjector().getInstance(HideMapLoadingSignal);
         if(_local2 != null)
         {
            _local2.dispatch();
         }
      }
      
      private function onPasswordPrompt(_arg1:PasswordPrompt) : void
      {
         if(_arg1.cleanPasswordStatus == 3)
         {
            TitleView.queuePasswordPromptFull = true;
         }
         else if(_arg1.cleanPasswordStatus == 2)
         {
            TitleView.queuePasswordPrompt = true;
         }
         else if(_arg1.cleanPasswordStatus == 4)
         {
            TitleView.queueRegistrationPrompt = true;
         }
         if(gs != null)
         {
            gs.closed.dispatch();
         }
         var _local2:HideMapLoadingSignal = StaticInjectorContext.getInjector().getInstance(HideMapLoadingSignal);
         if(_local2 != null)
         {
            _local2.dispatch();
         }
      }
      
      public function questFetch() : void
      {
         serverConnection.sendMessage(this.messages.require(51));
      }
      
      private function onQuestFetchResponse(_arg1:QuestFetchResponse) : void
      {
         this.questFetchComplete.dispatch(_arg1);
      }
      
      private function onQuestRedeemResponse(_arg1:QuestRedeemResponse) : void
      {
         this.questRedeemComplete.dispatch(_arg1);
      }
      
      public function questRedeem(_arg1:int, _arg2:int, _arg3:ItemData) : void
      {
         var _local4:QuestRedeem;
         (_local4 = this.messages.require(37) as QuestRedeem).slotObject.objectId_ = _arg1;
         _local4.slotObject.slotId_ = _arg2;
         _local4.slotObject.itemData_ = _arg3.toString();
         serverConnection.sendMessage(_local4);
      }
      
      public function keyInfoRequest(_arg1:int) : void
      {
         var _local2:KeyInfoRequest = this.messages.require(151) as KeyInfoRequest;
         _local2.itemType_ = _arg1;
         serverConnection.sendMessage(_local2);
      }
      
      private function onKeyInfoResponse(_arg1:KeyInfoResponse) : void
      {
         this.keyInfoResponse.dispatch(_arg1);
      }
      
      private function onClosed() : void
      {
         var _local1:* = null;
         if(this.playerId_ != -1)
         {
            gs.closed.dispatch();
         }
         else if(this.retryConnection_)
         {
            if(this.delayBeforeReconnect < 10)
            {
               if(this.delayBeforeReconnect == 6)
               {
                  _local1 = StaticInjectorContext.getInjector().getInstance(HideMapLoadingSignal);
                  _local1.dispatch();
               }
               this.retry(this.delayBeforeReconnect++);
               this.addTextLine.dispatch(ChatMessage.make("*Error*","Connection failed!  Retrying..."));
            }
            else
            {
               gs.closed.dispatch();
            }
         }
      }
      
      private function retry(_arg1:int) : void
      {
         this.retryTimer_ = new Timer(_arg1 * 1000,1);
         this.retryTimer_.addEventListener("timerComplete",this.onRetryTimer);
         this.retryTimer_.start();
      }
      
      private function onRetryTimer(_arg1:TimerEvent) : void
      {
         serverConnection.connect(server_.address,server_.port);
      }
      
      private function onError(_arg1:String) : void
      {
         this.addTextLine.dispatch(ChatMessage.make("*Error*",_arg1));
      }
      
      private function onFailure(_arg1:Failure) : void
      {
         var hideLoadingScreen:Signal = this.injector.getInstance(HideMapLoadingSignal);
         hideLoadingScreen && hideLoadingScreen.dispatch();
         switch(int(_arg1.errorId_) - 4)
         {
            case 0:
               this.handleIncorrectVersionFailure(_arg1);
               return;
            case 1:
               this.handleBadKeyFailure(_arg1);
               return;
            case 2:
               this.handleInvalidTeleportTarget(_arg1);
               return;
            case 3:
               this.handleEmailVerificationNeeded(_arg1);
               return;
            case 4:
               this.handleJsonDialog(_arg1);
               return;
            default:
               this.handleDefaultFailure(_arg1);
               return;
         }
      }
      
      private function handleJsonDialog(_arg1:Failure) : void
      {
         var dlg:* = null;
         var errorMsg:Object = JSON.parse(_arg1.errorDescription_);
         if("4.1.1" != errorMsg.build)
         {
            handleIncorrectVersionFailureBasic(errorMsg.build);
            return;
         }
         dlg = new Dialog(errorMsg.title,errorMsg.description,"Ok",null,null);
         dlg.addEventListener("dialogLeftButton",this.onDoClientUpdate);
         this.gs.addChild(dlg);
         this.retryConnection_ = false;
      }
      
      private function handleEmailVerificationNeeded(_arg1:Failure) : void
      {
         this.retryConnection_ = false;
         gs.closed.dispatch();
      }
      
      private function handleInvalidTeleportTarget(_arg1:Failure) : void
      {
         var _local2:String = LineBuilder.getLocalizedStringFromJSON(_arg1.errorDescription_);
         if(_local2 == "")
         {
            _local2 = _arg1.errorDescription_;
         }
         this.addTextLine.dispatch(ChatMessage.make("*Error*",_local2));
         this.player.nextTeleportAt_ = 0;
      }
      
      private function handleBadKeyFailure(_arg1:Failure) : void
      {
         var _local2:String = LineBuilder.getLocalizedStringFromJSON(_arg1.errorDescription_);
         if(_local2 == "")
         {
            _local2 = _arg1.errorDescription_;
         }
         this.addTextLine.dispatch(ChatMessage.make("*Error*",_local2));
         this.retryConnection_ = false;
         gs.closed.dispatch();
      }
      
      private function handleIncorrectVersionFailure(_arg1:Failure) : void
      {
         handleIncorrectVersionFailureBasic(_arg1.errorDescription_);
      }
      
      private function handleIncorrectVersionFailureBasic(description:String) : void
      {
         var _local2:Dialog = new Dialog("ClientUpdate.title","","ClientUpdate.leftButton",null,"/clientUpdate");
         _local2.setTextParams("ClientUpdate.description",{
            "client":"4.1.1",
            "server":description
         });
         _local2.addEventListener("dialogLeftButton",this.onDoClientUpdate);
         this.gs.addChild(_local2);
         this.retryConnection_ = false;
      }
      
      private function handleDefaultFailure(_arg1:Failure) : void
      {
         var _local2:String = LineBuilder.getLocalizedStringFromJSON(_arg1.errorDescription_);
         if(_local2 == "")
         {
            _local2 = _arg1.errorDescription_;
         }
         this.addTextLine.dispatch(ChatMessage.make("*Error*",_local2));
      }
      
      private function onDoClientUpdate(_arg1:Event) : void
      {
         var _local2:Dialog = _arg1.currentTarget as Dialog;
         _local2.parent.removeChild(_local2);
         gs.closed.dispatch();
      }
      
      public function isConnected() : Boolean
      {
         return serverConnection.isConnected();
      }
      
      private function setFocus(pkt:SetFocus) : void
      {
         var go:* = null;
         var goDict:Dictionary = this.gs.map.goDict;
         if(goDict)
         {
            go = goDict[pkt.objectId_];
            gs.setFocus(go);
            gs.hudView.setMiniMapFocus(go);
         }
      }
      
      public function requestMyMarketOffers() : void
      {
         var _loc1_:MarketCommand = this.messages.require(99) as MarketCommand;
         _loc1_.commandId = 0;
         serverConnection.sendMessage(_loc1_);
      }
      
      public function requestAllMarketOffers() : void
      {
         var _loc1_:MarketCommand = this.messages.require(99) as MarketCommand;
         _loc1_.commandId = 3;
         serverConnection.sendMessage(_loc1_);
      }
      
      public function removeMarketOffer(offerIds:Vector.<uint>) : void
      {
         var marketCommand:MarketCommand = this.messages.require(99) as MarketCommand;
         marketCommand.commandId = 2;
         marketCommand.offerIds = offerIds;
         serverConnection.sendMessage(marketCommand);
      }
      
      private function HandleMarketResult(param1:MarketResult) : void
      {
         switch(int(param1.commandId))
         {
            case 0:
            case 1:
               StaticInjectorContext.getInjector().getInstance(MarketResultSignal).dispatch(param1.message,param1.error);
               break;
            case 2:
               StaticInjectorContext.getInjector().getInstance(MarketItemsResultSignal).dispatch(param1.items);
         }
      }
      
      public function addOffer(param1:Vector.<MarketOffer>) : void
      {
         var _local_1:* = null;
         _local_1 = this.messages.require(99) as MarketCommand;
         _local_1.commandId = 1;
         _local_1.newOffers = param1;
         serverConnection.sendMessage(_local_1);
      }
      
      public function lootNotif(param1:kabam.rotmg.messaging.impl.incoming.LootNotification) : void
      {
         if(gs.contains(gs.map.lootNotification))
         {
            gs.removeChild(gs.map.lootNotification);
         }
         gs.map.lootNotification = new com.company.assembleegameclient.ui.lootNotification.LootNotification();
         gs.addChild(gs.map.lootNotification);
         gs.map.lootNotification.show(param1.item);
      }
      
      public function claimBattlePassItem(itemId:int, isPremium:Boolean) : void
      {
         var claimItemMessage:ClaimBattlePassItem = this.messages.require(179) as ClaimBattlePassItem;
         claimItemMessage.isPremium = isPremium;
         claimItemMessage.itemLevel = itemId;
         serverConnection.sendMessage(claimItemMessage);
      }
      
      public function lockItem(slotId:int, objectId:int, itemData:String) : void
      {
         var message:LockItem;
         (message = this.messages.require(182) as LockItem).slotObject_ = new SlotObjectData();
         message.slotObject_.slotId_ = slotId;
         message.slotObject_.objectId_ = objectId;
         message.slotObject_.itemData_ = itemData;
         serverConnection.sendMessage(message);
      }
   }
}
