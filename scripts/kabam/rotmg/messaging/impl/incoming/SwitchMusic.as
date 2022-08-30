package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class SwitchMusic extends IncomingMessage
   {
       
      
      public var music:String;
      
      public function SwitchMusic(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         this.music = param1.readUTF();
      }
      
      override public function toString() : String
      {
         return formatToString("SWITCHMUSIC","music_");
      }
   }
}
