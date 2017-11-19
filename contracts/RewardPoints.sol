pragma solidity ^0.4.15;

contract RewardPoints {

  mapping(string => mapping(string => uint)) rewardValues;
  mapping(string => mapping(string => uint)) reservedValues;


  function RewardPoints(uint256 _decimals) {
    // Any time a Commit is commented on.
    rewardValues['commit_comment']['created']        = 250 * 10**_decimals;

     // Any time a Branch or Tag is created.
    rewardValues['create']['repository']             = 2500 * 10**_decimals;
    rewardValues['create']['branch']                 = 150 * 10**_decimals;
    rewardValues['create']['tag']                    = 150 * 10**_decimals;

    // Any time a Branch or Tag is deleted.
    rewardValues['delete']['branch']                 = 0 * 10**_decimals;
    rewardValues['delete']['tag']                    = 0 * 10**_decimals;

     // Any time a Repository has a new deployment created from the API.
    rewardValues['deployment']['']                   = 1000 * 10**_decimals;

    // Any time a deployment for a Repository has a status update
    rewardValues['deployment_status']['success']     = 500 * 10**_decimals;
    rewardValues['deployment_status']['pending']     = 0 * 10**_decimals;
    rewardValues['deployment_status']['failure']     = 0 * 10**_decimals;
    rewardValues['deployment_status']['error']       = 0 * 10**_decimals;

    // Any time a Repository is forked.
    rewardValues['fork']['']                         = 100 * 10**_decimals;

     // Any time a Wiki page is updated.
    rewardValues['gollum']['created']                = 500 * 10**_decimals;
    rewardValues['gollum']['edited']                 = 50 * 10**_decimals;

    // Any time a GitHub App is installed or uninstalled.
    rewardValues['installation']['created']           = 1000 * 10**_decimals;
    rewardValues['installation']['deleted']           = 0 * 10**_decimals;

    // Any time a repository is added or removed from an organization (? check this)
    rewardValues['installation_repositories']['added']   = 1000 * 10**_decimals;
    rewardValues['installation_repositories']['removed'] = 0 * 10**_decimals;

     // Any time a comment on an issue is created, edited, or deleted.
    rewardValues['issues_comment']['created']           = 1000 * 10**_decimals;
    rewardValues['issues_comment']['edited']            = 250 * 10**_decimals;
    rewardValues['issues_comment']['deleted']           = 0 * 10**_decimals;

    // Any time an Issue is assigned, unassigned, labeled, unlabeled, opened, edited,
    rewardValues['issues']['assigned']               = 100 * 10**_decimals;
    rewardValues['issues']['unassigned']             = 0 * 10**_decimals;
    rewardValues['issues']['labeled']                = 50 * 10**_decimals;
    rewardValues['issues']['unlabeled']              = 0 * 10**_decimals;
    rewardValues['issues']['opened']                 = 500 * 10**_decimals;
    rewardValues['issues']['edited']                 = 100 * 10**_decimals;
    rewardValues['issues']['milestoned']             = 50 * 10**_decimals;
    rewardValues['issues']['demilestoned']           = 0 * 10**_decimals;
    rewardValues['issues']['closed']                 = 500 * 10**_decimals;
    rewardValues['issues']['reopened']               = 150 * 10**_decimals;

    // Any time a Label is created, edited, or deleted.
    rewardValues['label']['created']                 = 100 * 10**_decimals;
    rewardValues['label']['edited']                  = 50 * 10**_decimals;
    rewardValues['label']['deleted']                 = 0 * 10**_decimals;

    // Any time a user purchases, cancels, or changes their GitHub
    rewardValues['marketplace_purchase']['purchased'] = 1000 * 10**_decimals;
    rewardValues['marketplace_purchase']['cancelled'] = 0 * 10**_decimals;
    rewardValues['marketplace_purchase']['changed']   = 250 * 10**_decimals;

    // Any time a User is added or removed as a collaborator to a Repository, or has
    rewardValues['member']['added']                    = 1000 * 10**_decimals;
    rewardValues['member']['deleted']                  = 0 * 10**_decimals;
    rewardValues['member']['edited']                   = 250 * 10**_decimals;

    // Any time a User is added or removed from a team. Organization hooks only.
    rewardValues['membership']['added']                = 500 * 10**_decimals;
    rewardValues['membership']['removed']              = 0 * 10**_decimals;

    // Any time a Milestone is created, closed, opened, edited, or deleted.
    rewardValues['milestone']['created']               = 500 * 10**_decimals;
    rewardValues['milestone']['closed']                = 500 * 10**_decimals;
    rewardValues['milestone']['opened']                = 500 * 10**_decimals;
    rewardValues['milestone']['edited']                = 100 * 10**_decimals;
    rewardValues['milestone']['deleted']               = 0 * 10**_decimals;

    // Any time a user is added, removed, or invited to an Organization.
    rewardValues['organization']['member_added']       = 1000 * 10**_decimals;
    rewardValues['organization']['member_removed']     = 0 * 10**_decimals;
    rewardValues['organization']['member_invited']     = 1000 * 10**_decimals;

    // Any time an organization blocks or unblocks a user. Organization hooks only.
    rewardValues['org_block']['blocked']               = 0 * 10**_decimals;
    rewardValues['org_block']['unblocked']             = 0 * 10**_decimals;

     // Any time a Pages site is built or results in a failed build.
    rewardValues['page_build']['built']                = 2500 * 10**_decimals;

    // Any time a Project Card is created, edited, moved, converted to an issue,
    rewardValues['project_card']['created']           = 50 * 10**_decimals;
    rewardValues['project_card']['edited']            = 25 * 10**_decimals;
    rewardValues['project_card']['converted']         = 25 * 10**_decimals;
    rewardValues['project_card']['moved']             = 15 * 10**_decimals;
    rewardValues['project_card']['deleted']           = 0 * 10**_decimals;

    // Any time a Project Column is created, edited, moved, or deleted.
    rewardValues['project_column']['created']            = 50 * 10**_decimals;
    rewardValues['project_column']['edited']             = 25 * 10**_decimals;
    rewardValues['project_column']['moved']              = 15 * 10**_decimals;
    rewardValues['project_column']['deleted']            = 0 * 10**_decimals;

    // Any time a Project is created, edited, closed, reopened, or deleted.
    rewardValues['project']['created']                  = 2500 * 10**_decimals;
    rewardValues['project']['edited']                   = 100 * 10**_decimals;
    rewardValues['project']['closed']                   = 500 * 10**_decimals;
    rewardValues['project']['reopened']                 = 100 * 10**_decimals;

    rewardValues['pull_request_review_comment']['created']     = 250 * 10**_decimals;
    rewardValues['pull_request_review_comment']['edited']      = 100 * 10**_decimals;
    rewardValues['pull_request_review_comment']['deleted']     = 0 * 10**_decimals;

    // Any time a pull request review is submitted, edited, or dismissed.
    rewardValues['pull_request_review']['submitted']       = 250 * 10**_decimals;
    rewardValues['pull_request_review']['edited']          = 100 * 10**_decimals;
    rewardValues['pull_request_review']['dismissed']       = 100 * 10**_decimals;

    // Any time a pull request is assigned, unassigned, labeled, unlabeled, opened, edited, closed, reopened, or synchronized (updated due to a new push in the branch that the pull request is tracking). Also any time a pull request review is requested, or a review request is removed.
    rewardValues['pull_request']['assigned']               = 100 * 10**_decimals;
    rewardValues['pull_request']['unassigned']             = 0 * 10**_decimals;
    rewardValues['pull_request']['review_requested']       = 100 * 10**_decimals;
    rewardValues['pull_request']['review_request_removed'] = 0 * 10**_decimals;
    rewardValues['pull_request']['labeled']                = 50 * 10**_decimals;
    rewardValues['pull_request']['unlabeled']              = 0 * 10**_decimals;
    rewardValues['pull_request']['opened']                 = 100 * 10**_decimals;
    rewardValues['pull_request']['edited']                 = 50 * 10**_decimals;
    rewardValues['pull_request']['closed']                 = 100 * 10**_decimals;
    rewardValues['pull_request']['reopened']               = 15 * 10**_decimals;

    // Use when setting up the webhook for github
    rewardValues['ping']['']                               = 2500 * 10**_decimals;

    // Any Git push to a Repository, including editing tags or branches. Commits via API actions that update references are also counted. This is the default event.
    rewardValues['push']['']                               = 250 * 10**_decimals;

    // Any time a Release is published in a Repository.
    rewardValues['release']['published']                   = 5000 * 10**_decimals;

    // Any time a Repository is created, deleted (organization hooks only), made public, or made private.
    rewardValues['repository']['created']                  = 1000 * 10**_decimals;
    rewardValues['repository']['deleted']                  = 0 * 10**_decimals;
    rewardValues['repository']['publicized']               = 2500 * 10**_decimals;
    rewardValues['repository']['privatized']               = 0 * 10**_decimals;

    // Any time a Repository has a status update from the API
    rewardValues['status']['pending']                     = 0 * 10**_decimals;
    rewardValues['status']['success']                     = 500 * 10**_decimals;
    rewardValues['status']['failure']                     = 0 * 10**_decimals;
    rewardValues['status']['error']                       = 0 * 10**_decimals;

    // Any time a team is created, deleted, modified, or added to or removed from a repository. Organization hooks only
    rewardValues['team']['created']                       = 1000 * 10**_decimals;
    rewardValues['team']['deleted']                       = 0 * 10**_decimals;
    rewardValues['team']['edited']                        = 100 * 10**_decimals;
    rewardValues['team']['added_to_repository']           = 100 * 10**_decimals;
    rewardValues['team']['removed_from_repository']       = 0 * 10**_decimals;

    // Any time a team is added or modified on a Repository.
    rewardValues['team_add']['']                          = 1000 * 10**_decimals;

    // Any time a User stars a Repository.
    rewardValues['watch']['started']                      = 500 * 10**_decimals;


    // Any time a Commit is commented on.
    reservedValues['commit_comment']['created']           = 0 * 10**_decimals;

     // Any time a Branch or Tag is created.
    reservedValues['create']['repository']                = 500 * 10**_decimals;
    reservedValues['create']['branch']                    = 0 * 10**_decimals;
    reservedValues['create']['tag']                       = 0 * 10**_decimals;

    // Any time a Branch or Tag is deleted.
    reservedValues['delete']['branch']                    = 0 * 10**_decimals;
    reservedValues['delete']['tag']                       = 0 * 10**_decimals;

     // Any time a Repository has a new deployment created from the API.
    reservedValues['deployment']['']                      = 0 * 10**_decimals;

    // Any time a deployment for a Repository has a status update
    reservedValues['deployment_status']['success']        = 0 * 10**_decimals;
    reservedValues['deployment_status']['pending']        = 0 * 10**_decimals;
    reservedValues['deployment_status']['failure']        = 0 * 10**_decimals;
    reservedValues['deployment_status']['error']          = 0 * 10**_decimals;

    // Any time a Repository is forked.
    reservedValues['fork']['']                            = 1000 * 10**_decimals;

     // Any time a Wiki page is updated.
    reservedValues['gollum']['created']                   = 0 * 10**_decimals;
    reservedValues['gollum']['edited']                    = 0 * 10**_decimals;

    // Any time a GitHub App is installed or uninstalled.
    reservedValues['installation']['created']             = 0 * 10**_decimals;
    reservedValues['installation']['deleted']             = 0 * 10**_decimals;

    // Any time a repository is added or removed from an organization (? check this)
    reservedValues['installation_repositories']['added']   = 0 * 10**_decimals;
    reservedValues['installation_repositories']['removed'] = 0 * 10**_decimals;

     // Any time a comment on an issue is created, edited, or deleted.
    reservedValues['issues_comment']['created']           = 0 * 10**_decimals;
    reservedValues['issues_comment']['edited']            = 0 * 10**_decimals;
    reservedValues['issues_comment']['deleted']           = 0 * 10**_decimals;

    // Any time an Issue is assigned, unassigned, labeled, unlabeled, opened, edited,
    reservedValues['issues']['assigned']               = 0 * 10**_decimals;
    reservedValues['issues']['unassigned']             = 0 * 10**_decimals;
    reservedValues['issues']['labeled']                = 0 * 10**_decimals;
    reservedValues['issues']['unlabeled']              = 0 * 10**_decimals;
    reservedValues['issues']['opened']                 = 0 * 10**_decimals;
    reservedValues['issues']['edited']                 = 0 * 10**_decimals;
    reservedValues['issues']['milestoned']             = 0 * 10**_decimals;
    reservedValues['issues']['demilestoned']           = 0 * 10**_decimals;
    reservedValues['issues']['closed']                 = 0 * 10**_decimals;
    reservedValues['issues']['reopened']               = 0 * 10**_decimals;

    // Any time a Label is created, edited, or deleted.
    reservedValues['label']['created']                 = 0 * 10**_decimals;
    reservedValues['label']['edited']                  = 0 * 10**_decimals;
    reservedValues['label']['deleted']                 = 0 * 10**_decimals;

    // Any time a user purchases, cancels, or changes their GitHub
    reservedValues['marketplace_purchase']['purchased'] = 0 * 10**_decimals;
    reservedValues['marketplace_purchase']['cancelled'] = 0 * 10**_decimals;
    reservedValues['marketplace_purchase']['changed']   = 0 * 10**_decimals;

    // Any time a User is added or removed as a collaborator to a Repository, or has
    reservedValues['member']['added']                    = 0 * 10**_decimals;
    reservedValues['member']['deleted']                  = 0 * 10**_decimals;
    reservedValues['member']['edited']                   = 0 * 10**_decimals;

    // Any time a User is added or removed from a team. Organization hooks only.
    reservedValues['membership']['added']                = 0 * 10**_decimals;
    reservedValues['membership']['removed']              = 0 * 10**_decimals;

    // Any time a Milestone is created, closed, opened, edited, or deleted.
    reservedValues['milestone']['created']               = 0 * 10**_decimals;
    reservedValues['milestone']['closed']                = 15000 * 10**_decimals;
    reservedValues['milestone']['opened']                = 0 * 10**_decimals;
    reservedValues['milestone']['edited']                = 0 * 10**_decimals;
    reservedValues['milestone']['delete']                = 0 * 10**_decimals;

    // Any time a user is added, removed, or invited to an Organization.
    reservedValues['organization']['member_added']       = 15000 * 10**_decimals;
    reservedValues['organization']['member_removed']     = 0 * 10**_decimals;
    reservedValues['organization']['member_invited']     = 0 * 10**_decimals;

    // Any time an organization blocks or unblocks a user. Organization hooks only.
    reservedValues['org_block']['blocked']               = 0 * 10**_decimals;
    reservedValues['org_block']['unblocked']             = 0 * 10**_decimals;

     // Any time a Pages site is built or results in a failed build.
    reservedValues['page_build']['built']                = 0 * 10**_decimals;

    // Any time a Project Card is created, edited, moved, converted to an issue,
    reservedValues['project_card']['created']           = 0 * 10**_decimals;
    reservedValues['project_card']['edited']            = 0 * 10**_decimals;
    reservedValues['project_card']['converted']         = 0 * 10**_decimals;
    reservedValues['project_card']['moved']             = 0 * 10**_decimals;
    reservedValues['project_card']['deleted']           = 0 * 10**_decimals;

    // Any time a Project Column is created, edited, moved, or deleted.
    reservedValues['project_column']['created']            = 0 * 10**_decimals;
    reservedValues['project_column']['edited']             = 0 * 10**_decimals;
    reservedValues['project_column']['moved']              = 0 * 10**_decimals;
    reservedValues['project_column']['deleted']            = 0 * 10**_decimals;

    // Any time a Project is created, edited, closed, reopened, or deleted.
    reservedValues['project']['created']                  = 2500 * 10**_decimals;
    reservedValues['project']['edited']                   = 0 * 10**_decimals;
    reservedValues['project']['closed']                   = 500 * 10**_decimals;
    reservedValues['project']['reopened']                 = 0 * 10**_decimals;


    reservedValues['pull_request_review_comment']['created']     = 0 * 10**_decimals;
    reservedValues['pull_request_review_comment']['edited']      = 0 * 10**_decimals;
    reservedValues['pull_request_review_comment']['deleted']     = 0 * 10**_decimals;

    // Any time a pull request review is submitted, edited, or dismissed.
    reservedValues['pull_request_review']['submitted']       = 0 * 10**_decimals;
    reservedValues['pull_request_review']['edited']          = 0 * 10**_decimals;
    reservedValues['pull_request_review']['dismissed']       = 0 * 10**_decimals;

    // Any time a pull request is assigned, unassigned, labeled, unlabeled, opened, edited, closed, reopened, or synchronized (updated due to a new push in the branch that the pull request is tracking). Also any time a pull request review is requested, or a review request is removed.
    reservedValues['pull_request']['assigned']               = 0 * 10**_decimals;
    reservedValues['pull_request']['unassigned']             = 0 * 10**_decimals;
    reservedValues['pull_request']['review_requested']       = 0 * 10**_decimals;
    reservedValues['pull_request']['review_request_removed'] = 0 * 10**_decimals;
    reservedValues['pull_request']['labeled']                = 0 * 10**_decimals;
    reservedValues['pull_request']['unlabeled']              = 0 * 10**_decimals;
    reservedValues['pull_request']['opened']                 = 0 * 10**_decimals;
    reservedValues['pull_request']['edited']                 = 0 * 10**_decimals;
    reservedValues['pull_request']['closed']                 = 0 * 10**_decimals; // payload.merged
    reservedValues['pull_request']['reopened']               = 0 * 10**_decimals;

    // Use when setting up the webhook for github
    reservedValues['ping']['']                               = 5000 * 10**_decimals;

    // Any Git push to a Repository, including editing tags or branches. Commits via API actions that update references are also counted. This is the default event.
    reservedValues['push']['']                               = 0 * 10**_decimals;

    // Any time a Release is published in a Repository.
    reservedValues['release']['published']                   = 0 * 10**_decimals;

    // Any time a Repository is created, deleted (organization hooks only), made public, or made private.
    reservedValues['repository']['created']                  = 0 * 10**_decimals;
    reservedValues['repository']['deleted']                  = 0 * 10**_decimals;
    reservedValues['repository']['publicized']               = 0 * 10**_decimals;
    reservedValues['repository']['privatized']               = 0 * 10**_decimals;

    // Any time a Repository has a status update from the API
    reservedValues['status']['pending']                     = 0 * 10**_decimals;
    reservedValues['status']['success']                     = 0 * 10**_decimals;
    reservedValues['status']['failure']                     = 0 * 10**_decimals;
    reservedValues['status']['error']                       = 0 * 10**_decimals;

    // Any time a team is created, deleted, modified, or added to or removed from a repository. Organization hooks only
    reservedValues['team']['created']                       = 0 * 10**_decimals;
    reservedValues['team']['deleted']                       = 0 * 10**_decimals;
    reservedValues['team']['edited']                        = 0 * 10**_decimals;
    reservedValues['team']['added_to_repository']           = 0 * 10**_decimals;
    reservedValues['team']['removed_from_repository']       = 0 * 10**_decimals;

    // Any time a team is added or modified on a Repository.
    reservedValues['team_add']['']                          = 0 * 10**_decimals;

    // Any time a User stars a Repository.
    reservedValues['watch']['started']                      = 500 * 10**_decimals;
  }

  function getRewardDetails(string _event, string _subtype) public returns (uint _rewardValue, uint _reserveValue) {
    return (rewardValues[_event][_subtype], reservedValues[_event][_subtype]);
  }

}
