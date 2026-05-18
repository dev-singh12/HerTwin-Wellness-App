import '/components/community_tab_item/community_tab_item_widget.dart';
import '/components/interest_group/interest_group_widget.dart';
import '/components/story_card/story_card_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'community_feed_widget.dart' show CommunityFeedWidget;
import 'package:flutter/material.dart';

class CommunityFeedModel extends FlutterFlowModel<CommunityFeedWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CommunityTabItem.
  late CommunityTabItemModel communityTabItemModel1;
  // Model for CommunityTabItem.
  late CommunityTabItemModel communityTabItemModel2;
  // Model for CommunityTabItem.
  late CommunityTabItemModel communityTabItemModel3;
  // Model for InterestGroup.
  late InterestGroupModel interestGroupModel1;
  // Model for InterestGroup.
  late InterestGroupModel interestGroupModel2;
  // Model for InterestGroup.
  late InterestGroupModel interestGroupModel3;
  // Model for InterestGroup.
  late InterestGroupModel interestGroupModel4;
  // Model for StoryCard.
  late StoryCardModel storyCardModel1;
  // Model for StoryCard.
  late StoryCardModel storyCardModel2;
  // Model for StoryCard.
  late StoryCardModel storyCardModel3;

  @override
  void initState(BuildContext context) {
    communityTabItemModel1 =
        createModel(context, () => CommunityTabItemModel());
    communityTabItemModel2 =
        createModel(context, () => CommunityTabItemModel());
    communityTabItemModel3 =
        createModel(context, () => CommunityTabItemModel());
    interestGroupModel1 = createModel(context, () => InterestGroupModel());
    interestGroupModel2 = createModel(context, () => InterestGroupModel());
    interestGroupModel3 = createModel(context, () => InterestGroupModel());
    interestGroupModel4 = createModel(context, () => InterestGroupModel());
    storyCardModel1 = createModel(context, () => StoryCardModel());
    storyCardModel2 = createModel(context, () => StoryCardModel());
    storyCardModel3 = createModel(context, () => StoryCardModel());
  }

  @override
  void dispose() {
    communityTabItemModel1.dispose();
    communityTabItemModel2.dispose();
    communityTabItemModel3.dispose();
    interestGroupModel1.dispose();
    interestGroupModel2.dispose();
    interestGroupModel3.dispose();
    interestGroupModel4.dispose();
    storyCardModel1.dispose();
    storyCardModel2.dispose();
    storyCardModel3.dispose();
  }
}
