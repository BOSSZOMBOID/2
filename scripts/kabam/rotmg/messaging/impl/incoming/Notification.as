package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class Notification extends IncomingMessage
   {
       
      
      public var objectId_:int;
      
      public var text_:String;
      
      public var color_:int;
      
      public var playerId_:int;
      
      public function Notification(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         this.objectId_ = param1.readInt();
         this.text_ = param1.readUTF();
         this.color_ = param1.readInt();
         this.playerId_ = param1.readInt();
      }
      
      override public function toString() : String
      {
         return formatToString("NOTIFICATION","objectId_","text_","color_","playerId_");
      }
   }
}
