package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.ByteArray;
   import flash.utils.IDataOutput;
   
   public class Hello extends OutgoingMessage
   {
       
      
      public var buildVersion:String;
      
      public var gameId:int = 0;
      
      public var guid:String;
      
      public var loginToken:String;
      
      public var keyTime:int = 0;
      
      public var key:ByteArray;
      
      public var mapJSON:String;
      
      public var cliBytes:int = 0;
      
      public function Hello(id:uint, callback:Function)
      {
         this.key = new ByteArray();
         super(id,callback);
      }
      
      override public function writeToOutput(data:IDataOutput) : void
      {
         data.writeUTF(this.buildVersion);
         data.writeInt(this.gameId);
         data.writeUTF(this.guid);
         data.writeUTF(this.loginToken);
         data.writeInt(this.keyTime);
         data.writeShort(this.key.length);
         data.writeBytes(this.key);
         data.writeInt(this.mapJSON.length);
         data.writeUTFBytes(this.mapJSON);
         data.writeInt(this.cliBytes);
      }
      
      override public function toString() : String
      {
         return formatToString("HELLO","buildVersion","gameId","guid","loginToken","keyTime","key","mapJSON","cliBytes");
      }
   }
}
