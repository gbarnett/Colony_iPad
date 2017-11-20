//
//  DetailViewController.swift
//  Colony_iPad
//
//  Created by Gannon Barnett on 11/6/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak private var stackView: UIStackView!
    @IBOutlet var colony_DetailView: ColonyView!
    @IBOutlet var ControlsBar: UIView!
    
    func configureView() {
        colony_DetailView.setNeedsDisplay()
    }
    
    var colony : Colony = Colony()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colony_DetailView = self.stackView.subviews[0] as! ColonyView
        ControlsBar = view.subviews[1]
        colony_DetailView.colony = colony
        GenNumberLabel.text = "Generation \(colony_DetailView.colony.generation)"
        updateSpeedLabel()
        updateWrappingLabel()
        WrappingSwitch.setOn(colony_DetailView.colony.isWrapping(), animated: false)
        self.configureView()
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopEvolve()
    }
 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    //MARK:: CONTROLS BAR FUNCTIONS
    @IBAction func PlayButtonPressed(_ sender: Any) {
        evolveColony()
    }
    
    @IBAction func PauseButtonPressed(_ sender: Any) {
        stopEvolve()
    }
    
    func stopEvolve() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    @IBOutlet var EvolveSpeedLabel: UILabel!
    
    @IBOutlet var EvolveSpeedSlider: UISlider!
    
    var EvolveSpeedRawValue : Double {
        return Double(EvolveSpeedSlider.value)
    }
    
    @IBAction func EvolveSpeedChanged(_ sender: Any) {
        updateSpeedLabel()
    }

    @IBOutlet var GenNumberLabel: UILabel!
    
    @IBOutlet var WrappingStatusLabel: UILabel!

    @IBOutlet var WrappingSwitch: UISwitch!
    
    @IBAction func WrappingSwitchChanged(_ sender: Any) {
        colony_DetailView.colony.setWrappingTo(WrappingSwitch.isOn)
        updateWrappingLabel()
    }

    @IBAction func ClearButtonTouched(_ sender: Any) {
        colony_DetailView.colony.resetColony()
        configureView()
    }
    
    func updateWrappingLabel() {
        if colony_DetailView.colony.isWrapping() {
            WrappingStatusLabel.text = "Wrapping Enabled"
        } else {
            WrappingStatusLabel.text = "Wrapping Disabled"
        }
    }
    
    func updateSpeedLabel() {
        guard sliderRawtoTime() != nil else {
            EvolveSpeedLabel.text = "single step"
            return
        }
        
        let speed : String = String(describing: (sliderRawtoTime()! - sliderRawtoTime()!.truncatingRemainder(dividingBy: 0.1)))
        EvolveSpeedLabel.text = "\(speed)s / gen"
    }
    
    
    //change this value to change max speed of evolve
    let interval_MIN = 0.2
    
    var timer : Timer? = Timer()
    
    func sliderRawtoTime() -> Double? {
        if EvolveSpeedRawValue < 0.1 {
            return nil
        }
        return EvolveSpeedRawValue < 0.1 ? nil : interval_MIN / EvolveSpeedRawValue
    }
    
    func evolveColony() {
        let c = colony_DetailView.colony
        do {
            try c.evolve()
            configureView()
        }catch EvolveErrors.Colony_Dead {
            configureView()
            GenNumberLabel.text = "Colony Dead at gen \(colony_DetailView.colony.generation)"
            GenNumberLabel.backgroundColor = UIColor.red
            return
        }catch EvolveErrors.Colony_Stagnant {
            configureView()
            GenNumberLabel.text = "Colony Stagnant at gen \(colony_DetailView.colony.generation)"
            GenNumberLabel.backgroundColor = UIColor.red
            return
        }catch {
                print(Error.self)
        }
        
        GenNumberLabel.backgroundColor = UIColor.clear
        GenNumberLabel.text = "Generation \(colony_DetailView.colony.generation)"
        guard let interval = sliderRawtoTime() else {
            //do nothing. rawtime is nil. (not continuos)
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timerEvolve), userInfo: nil, repeats: false)
    }
    
    func timerEvolve() {
        timer?.invalidate()
        evolveColony()
    }
    
}

