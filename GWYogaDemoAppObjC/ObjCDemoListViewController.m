#import "ObjCDemoListViewController.h"

// Basic Layout
#import "ObjCFlexboxDirectionDemoViewController.h"
#import "ObjCJustifyContentDemoViewController.h"
#import "ObjCAlignItemsDemoViewController.h"
#import "ObjCFlexWrapGrowDemoViewController.h"
#import "ObjCAlignSelfDemoViewController.h"
#import "ObjCAlignContentDemoViewController.h"
#import "ObjCFlexBasisDemoViewController.h"
#import "ObjCDisplayDemoViewController.h"

// Sizing & Spacing
#import "ObjCWidthHeightDemoViewController.h"
#import "ObjCMarginDemoViewController.h"
#import "ObjCPaddingDemoViewController.h"
#import "ObjCGapDemoViewController.h"
#import "ObjCPositionDemoViewController.h"
#import "ObjCAspectRatioDemoViewController.h"

// Advanced
#import "ObjCGridDemoViewController.h"
#import "ObjCCompositeDemoViewController.h"

// Info demos
#import "ObjCVStackDemoViewController.h"
#import "ObjCScrollDemoViewController.h"
#import "ObjCCornerRadiusDemoViewController.h"
#import "ObjCShadowDemoViewController.h"
#import "ObjCBorderDemoViewController.h"
#import "ObjCOpacityClipsDemoViewController.h"
#import "ObjCDebugPrintDemoViewController.h"
#import "ObjCDebugBorderDemoViewController.h"
#import "ObjCSystemLayoutSizeDemoViewController.h"

@implementation ObjCDemoListViewController {
    NSArray<NSDictionary *> *_sections;
}

#define DEMO_ENTRY(cls, title) [NSDictionary dictionaryWithObjectsAndKeys:cls, @"class", title, @"title", nil]

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"GWYogaKit ObjC Demos";
    self.tableView = [[UITableView alloc] initWithFrame:self.tableView.frame style:UITableViewStyleInsetGrouped];

    _sections = @[
        @{@"name": @"Basic Layout", @"entries": @[
            DEMO_ENTRY(ObjCFlexboxDirectionDemoViewController.class, @"flexDirection"),
            DEMO_ENTRY(ObjCJustifyContentDemoViewController.class, @"justifyContent"),
            DEMO_ENTRY(ObjCAlignItemsDemoViewController.class, @"alignItems"),
            DEMO_ENTRY(ObjCFlexWrapGrowDemoViewController.class, @"flexWrap + grow"),
            DEMO_ENTRY(ObjCAlignSelfDemoViewController.class, @"alignSelf"),
            DEMO_ENTRY(ObjCAlignContentDemoViewController.class, @"alignContent"),
            DEMO_ENTRY(ObjCFlexBasisDemoViewController.class, @"flexBasis"),
            DEMO_ENTRY(ObjCDisplayDemoViewController.class, @"display"),
        ]},
        @{@"name": @"Sizing & Spacing", @"entries": @[
            DEMO_ENTRY(ObjCWidthHeightDemoViewController.class, @"width/height"),
            DEMO_ENTRY(ObjCMarginDemoViewController.class, @"margin"),
            DEMO_ENTRY(ObjCPaddingDemoViewController.class, @"padding"),
            DEMO_ENTRY(ObjCGapDemoViewController.class, @"gap"),
            DEMO_ENTRY(ObjCPositionDemoViewController.class, @"position"),
            DEMO_ENTRY(ObjCAspectRatioDemoViewController.class, @"aspectRatio"),
        ]},
        @{@"name": @"Advanced", @"entries": @[
            DEMO_ENTRY(ObjCGridDemoViewController.class, @"Grid"),
            DEMO_ENTRY(ObjCCompositeDemoViewController.class, @"Composite"),
        ]},
        @{@"name": @"Visual / Info", @"entries": @[
            DEMO_ENTRY(ObjCVStackDemoViewController.class, @"VStack / HStack"),
            DEMO_ENTRY(ObjCScrollDemoViewController.class, @"ScrollView"),
            DEMO_ENTRY(ObjCCornerRadiusDemoViewController.class, @"cornerRadius"),
            DEMO_ENTRY(ObjCShadowDemoViewController.class, @"shadow"),
            DEMO_ENTRY(ObjCBorderDemoViewController.class, @"border"),
            DEMO_ENTRY(ObjCOpacityClipsDemoViewController.class, @"opacity / clips"),
            DEMO_ENTRY(ObjCDebugPrintDemoViewController.class, @"debugPrint"),
            DEMO_ENTRY(ObjCDebugBorderDemoViewController.class, @"debugBorder"),
            DEMO_ENTRY(ObjCSystemLayoutSizeDemoViewController.class, @"systemLayoutSize"),
        ]},
    ];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_sections[section][@"entries"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _sections[section][@"name"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DemoCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DemoCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSDictionary *entry = _sections[indexPath.section][@"entries"][indexPath.row];
    cell.textLabel.text = entry[@"title"];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *entry = _sections[indexPath.section][@"entries"][indexPath.row];
    Class vcClass = entry[@"class"];
    UIViewController *vc = [[vcClass alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
