//
//  ViewController.h
//  felix-soundshaker
//
//  Created by Felix ITs 01 on 15/07/16.
//  Copyright © 2016 Aashish Tamsya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCSiriWaveformView.h"

@import AVFoundation;


@interface ViewController : UIViewController<AVAudioRecorderDelegate,AVAudioPlayerDelegate>
{
    AVAudioPlayer *player;
    AVAudioRecorder *recorder;
    AVAudioSession *session;
    BOOL hasRecorded;
}

@property (weak, nonatomic) IBOutlet UIButton *buttonRecord;
@property (weak, nonatomic) IBOutlet UIButton *buttonStop;
@property (weak, nonatomic) IBOutlet UIButton *buttonPlay;

- (IBAction)recordButtonTapped:(id)sender;
- (IBAction)stopButtonTapped:(id)sender;
- (IBAction)playButtonTapped:(id)sender;


@property (weak, nonatomic) IBOutlet SCSiriWaveformView *wave;



@end

