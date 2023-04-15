// Learn TypeScript:
//  - https://docs.cocos.com/creator/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/manual/en/scripting/life-cycle-callbacks.html

const {ccclass, property} = cc._decorator;

@ccclass
export default class NewClass extends cc.Component {
    @property
    speed: number = 0;

    private left:boolean = false
    private right:boolean = false
    private up:boolean = false
    private down:boolean = false

    // LIFE-CYCLE CALLBACKS:

    onLoad ()
    {
        this.left = false;
        this.right = false;
        this.up = false;
        this.down = false;
        //注册按钮事件
        cc.systemEvent.on(cc.SystemEvent.EventType.KEY_DOWN, this.onKeyDown, this);
        cc.systemEvent.on(cc.SystemEvent.EventType.KEY_UP, this.onKeyUp, this);
    }

    start () {

    }

    update (dt)
    {
        if(this.right)
         {
            //this.node.scaleX = 1;
            this.node.x += this.speed*dt;
         }
         else if(this.left)
         {
            //this.node.scaleX = -1;
            this.node.x-=this.speed*dt;
         }
        if(this.up)
        {
            this.node.y+=this.speed*dt;
        }
        else if(this.down)
        {
            this.node.y-=this.speed*dt
        }
    }

    onKeyDown(event)
     {
        switch(event.keyCode) 
        {      
                case cc.macro.KEY.d:
                this.right = true;
                break;
 
                case cc.macro.KEY.a:
                this.left = true;
                break;
 
                case cc.macro.KEY.w:
                this.up = true;
                break;
 
                case cc.macro.KEY.s:
                this.down = true;
                break;
         }
     }
 
     onKeyUp(event)
     {
        switch(event.keyCode)
        {
            case cc.macro.KEY.d:
            this.right = false;
            break;
 
            case cc.macro.KEY.a:
            this.left = false;
            break;
 
            case cc.macro.KEY.w:
            this.up = false;
            break;
 
            case cc.macro.KEY.s:
            this.down = false;
            break;
        }
     }
}
