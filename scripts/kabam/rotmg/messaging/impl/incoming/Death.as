package kabam.rotmg.messaging.impl.incoming
{
   import flash.display.BitmapData;
   import flash.utils.IDataInput;
   
   public class Death extends IncomingMessage
   {
       
      
      public var accountId_:int;
      
      public var charId_:int;
      
      public var killedBy_:String;
      
      public var background:BitmapData;
      
      public function Death(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      public function disposeBackground() : void
      {
         this.background && this.background.dispose();
         this.background = null;
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         this.accountId_ = param1.readInt();
         this.charId_ = param1.readInt();
         this.killedBy_ = param1.readUTF();
      }
      
      override public function toString() : String
      {
         return formatToString("DEATH","accountId_","charId_","killedBy_");
      }
   }
}
