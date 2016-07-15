//
//  ViewController.m
//  felix-soundshaker
//
//  Created by Felix ITs 01 on 15/07/16.
//  Copyright © 2016 Aashish Tamsya. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [self initializeApplication];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initializeApplication {
    
    [self.buttonPlay setEnabled:NO];
    [self.buttonStop setEnabled:NO];
    
    NSURL *outputFileURL = [self setupAudioPath];
    
    NSMutableDictionary *recorderSettings = [self setupRecorderSettings];
    
    [self setupAudioSession];
    
    [self initializeRecorderWithOutputFileURL:outputFileURL recorderSettings:recorderSettings];
    
    hasRecorded = NO;
    
}

-(NSURL*)setupAudioPath {
    
    //setting audio file path
    NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],@"MyAudioMemo.m4a", nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];

    return outputFileURL;
}

-(void)setupAudioSession {
    
    //setting up audio session
    session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
}

-(NSMutableDictionary *)setupRecorderSettings{

    //defining the recorder settings
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    
    return recordSetting;
}

-(void)initializeRecorderWithOutputFileURL:(NSURL *)outputFileURL recorderSettings:(NSMutableDictionary*)recordSetting {
    //initialize and prepare the recoder
    recorder = [[AVAudioRecorder alloc]initWithURL:outputFileURL settings:recordSetting error:NULL];
    
    //For demo purpose, we skip the error handling. In real app, don’t forget to include proper error handling.
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}

-(void)startRecording {
    [session setActive:YES error:nil];
    hasRecorded = YES;
    //start recording
    [recorder record];
    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}
-(void)startPlaying {
    
    if (hasRecorded) {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
        CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
        [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    else {
        [self displayAlertWithTitle:@"Error" message:@"You need to record first, in order to play."];
    }
    
}

- (IBAction)recordButtonTapped:(id)sender {
    
    UIButton *button = sender;
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        [button setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [self startRecording];
    }
    else {
        //pause recording
        [button setImage:[UIImage imageNamed:@"microphone"] forState:UIControlStateNormal];
        [recorder pause];
    }
    
    [self.buttonStop setEnabled:YES];
    [self.buttonPlay setEnabled:NO];
    
}

- (IBAction)stopButtonTapped:(id)sender {
    [recorder stop];
    [session setActive:NO error:nil];
}

- (IBAction)playButtonTapped:(id)sender {
    if (!recorder.recording){
        
        [self startPlaying];
    }
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    
    [self.buttonRecord setImage:[UIImage imageNamed:@"microphone"] forState:UIControlStateNormal];

    
    [self.buttonStop setEnabled:NO];
    [self.buttonPlay setEnabled:YES];
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    [self displayAlertWithTitle:@"Done" message:@"Finish playing the recording!"];
    
}


- (void)updateMeters
{
    CGFloat normalizedValue;
    if (player.playing) {
        [player updateMeters];
        normalizedValue = [self _normalizedPowerLevelFromDecibels:[player averagePowerForChannel:0]];
    }
    else if (recorder.recording) {
        [recorder updateMeters];
        normalizedValue = [self _normalizedPowerLevelFromDecibels:[recorder averagePowerForChannel:0]];

    }
    
    [self.wave updateWithLevel:normalizedValue];

}

- (CGFloat)_normalizedPowerLevelFromDecibels:(CGFloat)decibels
{
    if (decibels < -60.0f || decibels == 0.0f) {
        return 0.0f;
    }
    
    return powf((powf(10.0f, 0.05f * decibels) - powf(10.0f, 0.05f * -60.0f)) * (1.0f / (1.0f - powf(10.0f, 0.05f * -60.0f))), 1.0f / 2.0f);
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if ( event.subtype == UIEventSubtypeMotionShake )
    {
        // Put in code here to handle shake
        NSLog(@"Shake");
        [self startPlaying];
    }
    
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] )
        [super motionEnded:motion withEvent:event];
}

- (BOOL)canBecomeFirstResponder
{ return YES; }

-(void)displayAlertWithTitle: (NSString *)title message:(NSString*)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:alertController completion:nil];
    }];
    
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
