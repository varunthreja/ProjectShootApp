
//

import UIKit
import AVFoundation
class ViewController: UIViewController {

    @IBOutlet var start_btn: UIButton!
    @IBOutlet var sound_btn: UIButton!
    @IBOutlet var score_txt: UILabel!
    @IBOutlet var game_view: UIView!
    
    
    let PIX_M :Double=100 //scale between pixel and meter.---it means 10 pixel is 1 meter.
    
    var launcher: UIImageView = UIImageView(image:UIImage(named:"launcher.png"))//lancher image
    var rocket_move_state:Bool = false//rocket moved state if rocket is moved then true.
    var game_started_state:Bool = false//started game state if game is started then true.
    var start_touch_time = 0.0//start touched time seconds since 1970
    var end_touch_time = 0.0//end touched time seconds since 1970
    var start_touch_point : CGPoint = CGPoint(x: 0,y: 0)//start touched point
    var end_touch_point : CGPoint = CGPoint(x: 0,y: 0)//end touched point
    var speed_x=0.0//velocity x side of rocket
    var speed_y=0.0//velocity y side of rocket
    
    var sound_state:Bool = true //sound on || sound off state
    var background_music_thread:Thread?=nil//background music play thread
    
    //view widget width and height
    var width : CGFloat = 0.0
    var height : CGFloat = 0.0
    var score : Int = 0 // game score
    
    var target_array = [Target]()//target array
    var rocket = Rocket()//rocket object
    
    var timer_game : Timer?//action timer:game state updated by timer_game
    var timer_target: Timer?//add target timer
    
    //initial called function
    override func viewDidLoad() {
        super.viewDidLoad()
        //get screen width and height
        width=self.game_view.bounds.size.width
        height=self.game_view.bounds.size.height
        game_started_state = false

        background_music_thread=Thread.init(target: self, selector: #selector(self.playbackground_music), object: nil)
        background_music_thread?.start()//background music played
        sound_btn.setImage(UIImage(named: "soundoff.png"), for: UIControlState.normal)
        start_btn.isHidden = false
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//action when clicked "start" button
    @IBAction func game_start(_ sender: Any) {
        game_started_state = true
        rocket_move_state = false
        start_btn.isEnabled = true
        score = 0
        launcher.frame=CGRect(x: width/2-85, y: height-50.0, width: 170, height: 30)
        self.game_view.addSubview(launcher)
        init_rocket()
        start_btn.isHidden=true;
        timer_target=Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.appear_target), userInfo: nil, repeats: true)
        timer_game=Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.running_game), userInfo: nil, repeats: true)
    }

    //action when clicked "viewscore" button
    @IBAction func view_score(_ sender: Any) {
        background_music?.stop()
        background_music_thread?.cancel()
        background_music_thread=nil
        self.performSegue(withIdentifier: "home_score", sender: sender)
        //go to score view screen
    }
    
    //action when click "sound switch" icon
    @IBAction func sound_switch(_ sender: Any) {
        if sound_state {
            sound_state = false
            //stopped sound
            background_music?.stop()
            sound_btn.setImage(UIImage(named: "soundon.png"), for: UIControlState.normal)
        }
        else
        {
            //played sound
            background_music?.play()
            sound_btn.setImage(UIImage(named: "soundoff.png"), for: UIControlState.normal)
            sound_state = true
        }

    }
    
    
    
    
    
    
    /*--------------------------------    manage game action   -------------------------------*/
    func running_game()
    {
        //when rocket go out the game view then delete rocket
        if rocket_move_state {
            if (Float((rocket.image?.center.y)!) == 0.0)||(Float((rocket.image?.center.x)!) == 0.0)||(Float((rocket.image?.center.x)!) == Float(width)) {
                rocket.image?.removeFromSuperview()
                rocket_move_state = false
                init_rocket()
            }
            else
            {
                move_object(object: rocket.image!, move_x: rocket.speed_x, move_y: rocket.speed_y)
            }
        }
        
        
        //when rocket fit target then delete rocket and target, and increase score
        for target in target_array {
            if isfire(first: rocket.image!, second: target.image!) {
                
                rocket.image?.removeFromSuperview()
                rocket_move_state = false
                init_rocket()
                let index_target = target_array.index(of: target)!
                target_array.remove(at: index_target)
                target.image?.removeFromSuperview()
                score += 1
                score_txt.text="\(score)"
                //played explosion music
                let explosion_music_thread=Thread.init(target: self, selector: #selector(self.playexplosion_music), object: nil)
                explosion_music_thread.start()
                break
            }
        }
        
        
        
        //when target get bottom then game over popup showed
        for target in target_array {
            let val = Float((target.image?.center.y)!)
            if (val >= Float(height)) {
                
                //play boom music
                let explosion_music_thread=Thread.init(target: self, selector: #selector(self.playexplosion_music), object: nil)
                explosion_music_thread.start()
                
                
                //delete all object and go to start state
                target_array.removeAll()
                for subView in self.game_view.subviews as! [UIImageView]
                {
                    subView.removeFromSuperview()
                }
                rocket_move_state = false
                
                //show game over message
                let alert = UIAlertController(title: "Game Over!", message: "Score : \(score)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                game_started_state = false
                
                
                //save score
                let defaults = UserDefaults.standard
                let date = Date()
                let calender = Calendar.current
                let hour = calender.component(.hour, from:date)
                let minute = calender.component(.minute, from:date)
                let second = calender.component(.second, from:date)
                let count=defaults.integer(forKey: "value")
                let save_str:String!="\(score).\(hour):\(minute):\(second)"
                if count==0 {
                    defaults.set(1, forKey: "value")
                    defaults.set(save_str, forKey: "scores")
                }
                else
                {
                    let old_scores:String!=defaults.string(forKey: "scores");
                    let current_scores=old_scores + "," + save_str
                    defaults.set(current_scores, forKey: "scores")
                }
                defaults.synchronize()
                
                
                //can be available to click restart button
                //it is initialize setting
                start_btn.isHidden = false
                timer_target?.invalidate()
                timer_target = nil
                timer_game?.invalidate()
                timer_game = nil
                break
            }
        }
        
        
        //when target go out the game view then delete target in target array
        for target in target_array {
            let val = Float((target.image?.center.y)!)
            
            if (val < Float(height)) {
                move_object(object: target.image!, move_x: 0, move_y: target.speed)
            }
            else
            {
                let index = target_array.index(of: target)!
                target_array.remove(at: index)
                target.image?.removeFromSuperview()
            }
            move_object(object: target.image!, move_x: 0, move_y: target.speed)
            
        }

        
    }
/*----------------------------------------------------------------------------*/
    
    
    
    
    
    
/*-------------------------   generate target function   --------------------*/
    func appear_target() {
        let node = Target()
        let x = CGFloat(Int(arc4random())%Int(width))
        let point = CGPoint(x: x, y: 0)
        node.location = point
        //set imageview
        let imageView = UIImageView(image: UIImage(named: "airplane.png"))
        imageView.center = node.location
        node.image = imageView
        
        //add target
        target_array.append(node)
        self.game_view.addSubview(imageView)
    }
/*---------------------------------------------------------------------*/
 
    
    
    
    
    
/*-------------------------   initialize rocket function   --------------------*/
    func init_rocket() {
        //set initialize rocket position with launcher
        let x = self.launcher.center.x
        let y = self.launcher.center.y
        let point = CGPoint(x: x, y: y)
        rocket.location = point
        
        //set rocket image
        let image = UIImage(named: "rocket.png")
        let imageView = UIImageView(image: image!)
        imageView.center = rocket.location
        rocket.image = imageView
        //add rocket image to the game view
        self.game_view.addSubview(imageView)
    }
/*---------------------------------------------------------------------*/

    
    
    
    
/*--------------------- define playing music function --------------------*/
    // play music
    var background_music: AVAudioPlayer?
    var shoot_music: AVAudioPlayer?
    var explosion_music: AVAudioPlayer?
    
    // play background music
    func playbackground_music()
    {
        let url=Bundle.main.url(forResource: "background", withExtension: "mp3")!
        
        do {
            background_music = try AVAudioPlayer(contentsOf: url)
            background_music?.numberOfLoops = -1
            guard let background_music = background_music else { return }
            background_music.volume=0.5
            background_music.prepareToPlay()
            background_music.play()
        } catch let error as NSError {
            print(error.description)
        }
        
    }
/*----------------------------------------------------------------------*/
    
    
    
    
/*------------------------  play fire gun music function  ------------------*/
    func playfire_music() {
        
        let url=Bundle.main.url(forResource: "fire", withExtension: "mp3")!
        
        do {
            shoot_music = try AVAudioPlayer(contentsOf: url)
            guard let shoot_music = shoot_music else { return }
            shoot_music.volume=1
            shoot_music.prepareToPlay()
            shoot_music.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
/*---------------------------------------------------------------------------*/
    
    
    
    
/*-------------------------- play boom music function -----------------------------*/
    func playexplosion_music() {
        
        let url=Bundle.main.url(forResource: "explosion", withExtension: "mp3")!
        
        do {
            explosion_music = try AVAudioPlayer(contentsOf: url)
            guard let explosion_music = explosion_music else { return }
            explosion_music.volume=1
            explosion_music.prepareToPlay()
            explosion_music.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
/*----------------------------------------------------------------------*/
    

    
    
    
    
    
    
/*----------------  determine hit between two imageview --------------*/
    func isfire(first:UIImageView,second:UIImageView) -> Bool {
        if (abs(first.center.x-second.center.x)<(first.frame.size.width/2.0+second.frame.width/2.0-2.0)&&abs(first.center.y-second.center.y)<(first.frame.size.height/2.0+second.frame.height/2.0-2.0)) {
            return true
        }
        else
        {
            return false
        }
    }
/*-------------------------------------------------------------------*/
    
    
    
    
    
    
    
/*--------------------------  move function  -------------------------*/
    //move object x-side with move_x and y-side with move_y
    func move_object(object:UIImageView , move_x:CGFloat , move_y : CGFloat){
        let pos_x = object.center.x
        let pos_y = object.center.y
        var last_x = pos_x
        var last_y = pos_y
        if pos_x+move_x<0 {
            last_x = 0.0
        }
        else if pos_x+move_x > width {
            last_x = width
        }else{
            last_x = pos_x+move_x
        }
        
        if pos_y+move_y<0 {
            last_y = 0.0
        }
        else if pos_y+move_y > height {
            last_y = height
        }else{
            last_y = pos_y+move_y
        }
        object.center=CGPoint(x: last_x, y: last_y)
        
    }
/*-------------------------------------------------------------------*/
    
    

    //when touch screen then this function called
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.rocket_move_state == false && game_started_state {
            var all_touches=Array(touches)
            let touch=all_touches[0]
            
            //set start touched point and touched time
            self.start_touch_point = touch.location(in: self.game_view)
            self.start_touch_time=Date().timeIntervalSince1970
            print("touch point (x,y)=(\(start_touch_point.x),\(start_touch_point.y))-----\(start_touch_time)")
        }
    }
    
    //when released touch then this function called
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.rocket_move_state == false && game_started_state{
            var all_touches=Array(touches)
            let touch=all_touches[0]
            //get end touched point and touched time
            self.end_touch_point = touch.location(in: self.game_view)
            self.end_touch_time=Date().timeIntervalSince1970
            print("touch point (x,y)=(\(end_touch_point.x),\(end_touch_point.y))-----\(end_touch_time)")
            
            //calculate rocket speed and arrow
            self.speed_x=Double(self.end_touch_point.x-self.start_touch_point.x)/(self.end_touch_time-self.start_touch_time)/PIX_M
            self.speed_y=Double(self.end_touch_point.y-self.start_touch_point.y)/(self.end_touch_time-self.start_touch_time)/PIX_M
            
            //set rocket speed
            let fire_music_thread=Thread.init(target: self, selector: #selector(self.playfire_music), object: nil)
            rocket.speed_x = CGFloat(speed_x)
            rocket.speed_y = CGFloat(speed_y)
            self.rocket_move_state = true;
            fire_music_thread.start()
        }
    }    
}

