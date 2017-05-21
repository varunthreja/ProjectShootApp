

import UIKit
//it represented view score screen
class ScoreView: UIViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet var score_table: UITableView!
    var score_array:[String] = []//scores array

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //set table row count
        return score_array.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //show score data in each cells
        
        let cell=self.score_table.dequeueReusableCell(withIdentifier: "Cell") as! NodeCell
        let score_node:[String]=score_array[indexPath.row].components(separatedBy: ".")
        cell.number.text="\(indexPath.row)"
        cell.score.text="\(score_node[0])"
        cell.time.text="\(score_node[1])"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //get history data from userdefaults
        let defaults = UserDefaults.standard
        let value=defaults.integer(forKey: "value")
        
        if value==1 {
            let str = defaults.string(forKey: "scores")!
            print(str)
            score_array=(str.components(separatedBy: ","))
        }
        defaults.synchronize()
        
        //reload data to the table
        score_table.reloadData();
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clear_click(_ sender: Any) {
        
        //clear history data
        let defaults = UserDefaults.standard
        defaults.set(0, forKey: "value")
        defaults.set(nil, forKey: "scores")
        defaults.synchronize()
        score_array = []
        score_table.reloadData();
    }

    @IBAction func back_click(_ sender: Any) {
        //go to home screen
        self.performSegue(withIdentifier: "score_home", sender: sender)
        //score_home
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
