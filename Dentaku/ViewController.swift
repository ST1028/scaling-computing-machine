import UIKit
import AVFoundation

//生成するボタン名とタグ番号の紐付け
enum numBtnTag: Int {
    case Zero = 1, one,two, three, four, five, six, seven, eight, nine, doublezero
    static let allValues: [numBtnTag] = [Zero, one,two, three, four, five, six, seven, eight, nine, doublezero]
    
    func toStr() -> String {
        if self == doublezero {
            return "00"
        }else{
            return String(self.rawValue - 1)
        }
    }
}

//生成するボタン名とタグ番号の紐付け
enum kigouBtnTag: Int {
    case Kigou = 1, ikouru, plus, mainasu, kakeru, waru, ac, plusmainasu, backcolor
    static let allValues: [kigouBtnTag] = [Kigou, ikouru, plus, mainasu, kakeru, waru, ac, plusmainasu, backcolor]
    
    func toStr() -> String {
        switch self {
        case .ikouru:
            return "="
        case .plus:
            return "+"
        case .mainasu:
            return "-"
        case .kakeru:
            return "×"
        case .waru:
            return "÷"
        case .ac:
            return "AC"
        case .plusmainasu:
            return "+/-"
        case .backcolor:
            return "BC"
        default:
            return "."
        }
    }
}

//計算関数
func resultKeisan (num:Double , kigou:String, result:Double) -> Double {
    var keisan:Double
    Flg.count = 1
    switch kigou {
    case "+":
        keisan = (num) + (result)
    case "-":
        keisan = (num) - (result)
    case "×":
        keisan = (num) * (result)
    case "÷":
        keisan = (num) / (result)
    default:
        keisan = 0
    }
    return keisan
}


//表示桁数チェック
func viewNum(num:Double) -> String {
    let formatter = NSNumberFormatter()
    if num >= 1000000000 {
        formatter.numberStyle = .ScientificStyle
    } else {
        formatter.numberStyle = .DecimalStyle
    }
    formatter.maximumFractionDigits = 9
    var result = formatter.stringFromNumber(num)
    var date:NSDate = NSDate();
    let dateFormater = NSDateFormatter()
    dateFormater.dateFormat = "MMdd";
    var Date:String = dateFormater.stringFromDate(date)
    formatter.numberStyle = .DecimalStyle
    var Check = formatter.stringFromNumber(Date.toInt()!)
    
    if  Check == result {
        todayPlayer.play()
    }
    return result!
}


//電卓用変数
var num : Double = 0
var kigou : String!
var num2 : Double = 0
var Flg = (num:0,dotto:0,count:1.0)
var countCheck = 0

//BGM用変数
var btnBGM = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("btnBGM", ofType:"mp3")!)
var player = AVAudioPlayer()
var todayBGM = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("ff_fanfare", ofType:"mp3")!)
var todayPlayer = AVAudioPlayer()


class ViewController: UIViewController {
    private var effectView : UIVisualEffectView!
    private var Label : UILabel!
    
    //背景色選択
    func selectColor() {
        let controller = UIAlertController(title: "Select Color",message: nil,preferredStyle: .ActionSheet)
        let color_1 = UIAlertAction(title: "Gray", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction!) in
            self.view.backgroundColor = UIColor.grayColor()
        })
        let color_2 = UIAlertAction(title: "Blue", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction!) in
            self.view.backgroundColor = UIColor.blueColor()
        })
        let color_3 = UIAlertAction(title: "Green", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction!) in
            self.view.backgroundColor = UIColor.greenColor()
        })
        let color_4 = UIAlertAction(title: "Yellow", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction!) in
            self.view.backgroundColor = UIColor.yellowColor()
        })
        
        controller.addAction(color_1)
        controller.addAction(color_2)
        controller.addAction(color_3)
        controller.addAction(color_4)
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //playerの生成
        player = AVAudioPlayer(contentsOfURL: btnBGM, error: nil)
        player.prepareToPlay()
        todayPlayer = AVAudioPlayer(contentsOfURL: todayBGM, error: nil)
        todayPlayer.prepareToPlay()
        
        self.view.backgroundColor = UIColor.grayColor()
        
        //BlurEffectViewの生成。styleはExtraLight
        let blurEffect = UIBlurEffect(style:.ExtraLight)
        let visualEffectView = UIVisualEffectView(effect:blurEffect)
        visualEffectView.frame = self.view.frame;
        
        //blur効果をかけたいviewを作成
        let view = UIView(frame:self.view.frame)
        
        //blur効果viewのcontentViewにblur効果かけたいviewを追加
        visualEffectView.contentView.addSubview(view)
        
        //表示
        self.view.addSubview(visualEffectView)
        
        //電卓ラベルの生成
        Label = UILabel(frame: CGRectMake(0,0,self.view.frame.width,(self.view.bounds.height / 7) * 2 ))
        Label.textAlignment = NSTextAlignment.Right
        Label.font = UIFont.systemFontOfSize(50)
        Label.text = "0"
        Label.backgroundColor = UIColor.blackColor()
        Label.textColor = UIColor.whiteColor()
        Label.shadowColor = UIColor.grayColor()
        Label.alpha = 0.3
        self.view.addSubview(Label)
        
        //各機種ごとの割合率
        var btnSize : CGFloat = (self.view.bounds.width / 4) - (self.view.bounds.width / 15)
        var yParcent = self.view.bounds.width / self.view.bounds.height * 100
        var yPoint:CGFloat = 0
        btnSize = (self.view.bounds.width / 4) - (self.view.bounds.width / 12.5)
        yPoint = self.view.frame.width / 4 / 2.1
        
        //数字ボタンを生成
        for btag in numBtnTag.allValues {
            var x:CGFloat = 0
            var y:CGFloat = 0
            var btn :UIButton = UIButton()
            
            btn.backgroundColor = UIColor.whiteColor()
            btn.alpha = 0.65
            btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            btn.layer.masksToBounds = true
            btn.layer.cornerRadius = btnSize / 2
            btn.frame = CGRectMake(0,0,btnSize,btnSize)

            //y軸の確定
            switch btag.toStr() {
            case "0":
                x = ((self.view.frame.width / 4) / 2 )
                y = ((self.view.bounds.height / 7 ) * 7) - yPoint
            case "00":
                x = ((self.view.frame.width / 4) / 2 ) * 3
                y = ((self.view.bounds.height / 7 ) * 7) - yPoint
            case "1","2","3":
                y = ((self.view.bounds.height / 7 ) * 6) - yPoint
            case "4","5","6":
                y = ((self.view.bounds.height / 7 ) * 5) - yPoint
            case "7","8","9":
                y = ((self.view.bounds.height / 7 ) * 4) - yPoint
            default:
                break
            }
            
            //x軸の確定
            switch btag.toStr() {
            case "1","4","7":
                x = ((self.view.frame.width / 4) / 2 )
            case "2","5","8":
                x = ((self.view.frame.width / 4) / 2 ) * 3
            case "3","6","9":
                x = ((self.view.frame.width / 4) / 2 ) * 5
            default:
                break
            }
            
            btn.layer.position = CGPoint(x:x,y:y)
            //ボタンのタグを設定
            btn.tag = btag.rawValue
            btn.setTitle(btag.toStr(), forState: .Normal)
            btn.addTarget(self, action: "numpushed:", forControlEvents: .TouchUpInside)
            self.view.addSubview(btn)
        }
        
        //記号ボタンを生成
        for btag in kigouBtnTag.allValues {
            var x:CGFloat = 0
            var y:CGFloat = 0
            var btn :UIButton = UIButton()
            //let btnSize : CGFloat = (self.view.bounds.width / 4) - (self.view.bounds.width / 15)
            btn.backgroundColor = UIColor.whiteColor()
            btn.alpha = 0.75
            btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            btn.layer.masksToBounds = true
            btn.layer.cornerRadius = btnSize / 2
            btn.frame = CGRectMake(0,0,btnSize,btnSize)
            btn.tag = btag.rawValue
            
            //y軸の確定
            switch btag.toStr() {
            case ".","=":
                y = ((self.view.bounds.height / 7 ) * 7) - yPoint
            case "+":
                y = ((self.view.bounds.height / 7 ) * 6) - yPoint
            case "-":
                y = ((self.view.bounds.height / 7 ) * 5) - yPoint
            case "×":
                y = ((self.view.bounds.height / 7 ) * 4) - yPoint
            default:
                y = ((self.view.bounds.height / 7 ) * 3) - yPoint
            }
            
            //x軸の確定
            switch btag.toStr() {
            case "BC":
                x = ((self.view.frame.width / 4) / 2 )
            case "AC":
                x = ((self.view.frame.width / 4) / 2 ) * 3
            case "+/-",".":
                x = ((self.view.frame.width / 4) / 2 ) * 5
            default:
                x = ((self.view.frame.width / 4) / 2 ) * 7
            }
            
            btn.setTitle(btag.toStr(), forState: .Normal)
            btn.layer.position = CGPoint(x:x,y:y)
            btn.addTarget(self, action: "kigouPushed:", forControlEvents: .TouchUpInside)
            self.view.addSubview(btn)
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //numの準備
    func numCheck (numLocal:String) -> String {
        var result:Double!
        switch numLocal {
        case "0":
            if Flg.dotto == 0 {
                result = num * 10
            } else {
                Flg.count = Flg.count * 10
                result = num + atof(numLocal) * (1.0 / Flg.count)
            }
        case "00":
            if Flg.dotto == 0 {
                result = num * 100
            } else {
                Flg.count = Flg.count * 100
                result = num + atof(numLocal) * (1.0 / Flg.count)
            }
        default:
            if num < 0 && Flg.dotto == 1 {
                Flg.count = Flg.count * 10
                result = num - atof(numLocal) * (1.0 / Flg.count)
            } else if num < 0 {
                result = num * 10 - atof(numLocal)
            } else if Flg.dotto == 0 {
                result = num * 10 + atof(numLocal)
            } else {
                Flg.count = Flg.count * 10
                result = num + atof(numLocal) * (1.0 / Flg.count)
           }
        }
        num = result
        return String(stringInterpolationSegment: result)
    }

    //num2の準備
    func num2Check (numLocal:String) -> String {
        var result:Double!
        switch numLocal {
        case "0":
            if Flg.dotto == 0 {
                result = num2 * 10
            } else {
                Flg.count = Flg.count * 10
                result = num2 + (atof(numLocal) * (1.0 / Flg.count))
            }
        case "00":
            if Flg.dotto == 0 {
                result = num2 * 100
            } else {
                Flg.count = Flg.count * 100
                result = num2 + (atof(numLocal) * (1.0 / Flg.count))
            }
        default:
            if num2 < 0  && Flg.dotto == 1 {
                Flg.count = Flg.count * 10
                result = num2 - atof(numLocal) * (1.0 / Flg.count)
            } else if num2 < 0 {
                result = num2 * 10 - atof(numLocal)
            } else if Flg.dotto == 0 {
                result = num2 * 10 + atof(numLocal)
            } else {
                Flg.count = Flg.count * 10
                result = num2 + atof(numLocal) * (1.0 / Flg.count)
            }
        }
        num2 = result
        return String(stringInterpolationSegment: result)
    }

    
    //数字ボタンのプッシュ時
    func numpushed(sender: UIButton){
        var btag = numBtnTag(rawValue: sender.tag)!
        player.play()
        countCheck++
        if Flg.num == 0  && countCheck < 10 {
            Label.text = viewNum(atof(numCheck(btag.toStr())))
        } else if Flg.num == 1 && countCheck < 10 {
            Label.text = viewNum(atof(num2Check(btag.toStr())))
        }
    }
    
    //記号ボタンのプッシュ時
    func kigouPushed(sender: UIButton){
        player.play()
        var btag = kigouBtnTag(rawValue: sender.tag)!
        switch btag.toStr() {
        case "+","-","×","÷":
            if kigou == nil {
                kigou = btag.toStr()
                Flg.num = 1
                Flg.dotto = 0
                Flg.count = 1
                countCheck = 0
            } else {
                var result = resultKeisan(num, kigou, num2)
                Label.text = viewNum(result)
                num = result
                num2 = 0
                kigou = btag.toStr()
                Flg.num = 1
                Flg.dotto = 0
                Flg.count = 1
                countCheck = 0
            }
        case "=":
            if kigou == nil {
                break
            } else {
                var result = resultKeisan(num, kigou, num2)
                Label.text = viewNum(result)
                num = result
                num2 = 0
                kigou = nil
                Flg.num = 1
                Flg.dotto = 0
                Flg.count = 1
                countCheck = 0
            }
        case "AC":
            num = 0
            num2 = 0
            kigou = nil
            Label.text = "0"
            Flg.num = 0
            Flg.dotto = 0
            Flg.count = 1
            countCheck = 0
        case "+/-":
            if Flg.num == 0 {
                num = num * -1
                Label.text = viewNum(num)
            } else {
                num2 = num2 * -1
                Label.text = viewNum(num2)
            }
        case "BC":
            selectColor()
        case ".":
            Flg.dotto = 1
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}