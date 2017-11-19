var RewardPoints = artifacts.require("./RewardPoints.sol");
var Promise = require("bluebird")
const { decimals } = require('../gittoken.config')
var toPowerOf = require('../utils/toPowerOf')

var Contract;

contract('RewardPoints', function(accounts) {
  describe("RewardPoints::getRewardDetails", function() {
    it(`Should check the reward values for contributions events`, function() {
      initContract().then(function(contract) {
        Contract = contract
        return rewardDetails
      }).map((details) => {
        const { event, subevent } = details
        return Promise.join(
          details,
          Contract.getRewardDetails.call(event, subevent)
        )
      }).map((data) => {
        const { rewardValue, reserveValue } = data[0]
        const values = data[1]

        assert.equal(values[0].toNumber(), rewardValue, `Expected reward value to equal ${rewardValue}`)
        assert.equal(values[1].toNumber(), reserveValue, `Expected reserve value to equal ${reserveValue}`)

      }).catch(function(error) {
        assert.equal(error, null, error.message)
      })
    })
  })
});



const rewardDetails = [{
  event: 'commit_comment',
  subevent: 'created',
  rewardValue: toPowerOf(250, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'create',
  subevent: 'repository',
  rewardValue: toPowerOf(2500, decimals),
  reserveValue: toPowerOf(500, decimals)
},{
  event: 'create',
  subevent: 'branch',
  rewardValue: toPowerOf(150, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'create',
  subevent: 'tag',
  rewardValue: toPowerOf(150, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'delete',
  subevent: 'branch',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'delete',
  subevent: 'tag',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'deployment',
  subevent: '',
  rewardValue: toPowerOf(1000, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'deployment_status',
  subevent: 'success',
  rewardValue: toPowerOf(500, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'deployment_status',
  subevent: 'pending',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'deployment_status',
  subevent: 'failure',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'deployment_status',
  subevent: 'error',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'fork',
  subevent: '',
  rewardValue: toPowerOf(100, decimals),
  reserveValue: toPowerOf(1000, decimals)
},{
  event: 'gollum',
  subevent: 'created',
  rewardValue: toPowerOf(500, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'gollum',
  subevent: 'edited',
  rewardValue: toPowerOf(50, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'installation',
  subevent: 'created',
  rewardValue: toPowerOf(1000, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'installation',
  subevent: 'deleted',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'installation_repositories',
  subevent: 'added',
  rewardValue: toPowerOf(1000, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'installation_repositories',
  subevent: 'removed',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'issues_comment',
  subevent: 'created',
  rewardValue: toPowerOf(1000, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'issues_comment',
  subevent: 'edited',
  rewardValue: toPowerOf(250, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'issues_comment',
  subevent: 'deleted',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'issues',
  subevent: 'assigned',
  rewardValue: toPowerOf(100, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'issues',
  subevent: 'unassigned',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'issues',
  subevent: 'labeled',
  rewardValue: toPowerOf(50, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'issues',
  subevent: 'unlabeled',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'issues',
  subevent: 'opened',
  rewardValue: toPowerOf(500, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'issues',
  subevent: 'edited',
  rewardValue: toPowerOf(100, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'issues',
  subevent: 'milestoned',
  rewardValue: toPowerOf(50, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'issues',
  subevent: 'demilestoned',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'issues',
  subevent: 'closed',
  rewardValue: toPowerOf(500, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'issues',
  subevent: 'reopened',
  rewardValue: toPowerOf(150, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'label',
  subevent: 'created',
  rewardValue: toPowerOf(100, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'label',
  subevent: 'edited',
  rewardValue: toPowerOf(50, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'label',
  subevent: 'deleted',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'marketplace_purchase',
  subevent: 'purchased',
  rewardValue: toPowerOf(1000, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'marketplace_purchase',
  subevent: 'cancelled',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'marketplace_purchase',
  subevent: 'changed',
  rewardValue: toPowerOf(250, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'member',
  subevent: 'added',
  rewardValue: toPowerOf(1000, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'member',
  subevent: 'deleted',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'member',
  subevent: 'edited',
  rewardValue: toPowerOf(250, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'membership',
  subevent: 'added',
  rewardValue: toPowerOf(500, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'membership',
  subevent: 'removed',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'milestone',
  subevent: 'created',
  rewardValue: toPowerOf(500, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'milestone',
  subevent: 'closed',
  rewardValue: toPowerOf(500, decimals),
  reserveValue: toPowerOf(15000, decimals)
},{
  event: 'milestone',
  subevent: 'opened',
  rewardValue: toPowerOf(500, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'milestone',
  subevent: 'edited',
  rewardValue: toPowerOf(100, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'milestone',
  subevent: 'deleted',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'organization',
  subevent: 'member_added',
  rewardValue: toPowerOf(1000, decimals),
  reserveValue: toPowerOf(15000, decimals)
},{
  event: 'organization',
  subevent: 'member_removed',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'organization',
  subevent: 'member_invited',
  rewardValue: toPowerOf(1000, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'org_block',
  subevent: 'blocked',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'org_block',
  subevent: 'unblocked',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'page_build',
  subevent: 'built',
  rewardValue: toPowerOf(2500, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'project_card',
  subevent: 'created',
  rewardValue: toPowerOf(50, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'project_card',
  subevent: 'edited',
  rewardValue: toPowerOf(25, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'project_card',
  subevent: 'converted',
  rewardValue: toPowerOf(25, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'project_card',
  subevent: 'moved',
  rewardValue: toPowerOf(15, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'project_card',
  subevent: 'deleted',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'project_column',
  subevent: 'created',
  rewardValue: toPowerOf(50, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'project_column',
  subevent: 'edited',
  rewardValue: toPowerOf(25, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'project_column',
  subevent: 'moved',
  rewardValue: toPowerOf(15, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'project_column',
  subevent: 'deleted',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'project',
  subevent: 'created',
  rewardValue: toPowerOf(2500, decimals),
  reserveValue: toPowerOf(2500, decimals)
},{
  event: 'project',
  subevent: 'edited',
  rewardValue: toPowerOf(100, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'project',
  subevent: 'closed',
  rewardValue: toPowerOf(500, decimals),
  reserveValue: toPowerOf(500, decimals)
},{
  event: 'project',
  subevent: 'reopened',
  rewardValue: toPowerOf(100, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'pull_request_review_comment',
  subevent: 'created',
  rewardValue: toPowerOf(250, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'pull_request_review_comment',
  subevent: 'edited',
  rewardValue: toPowerOf(100, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'pull_request_review_comment',
  subevent: 'deleted',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'pull_request_review',
  subevent: 'submitted',
  rewardValue: toPowerOf(250, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'pull_request_review',
  subevent: 'edited',
  rewardValue: toPowerOf(100, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'pull_request_review',
  subevent: 'dismissed',
  rewardValue: toPowerOf(100, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'pull_request',
  subevent: 'assigned',
  rewardValue: toPowerOf(100, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'pull_request',
  subevent: 'unassigned',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'pull_request',
  subevent: 'review_requested',
  rewardValue: toPowerOf(100, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'pull_request',
  subevent: 'review_request_removed',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'pull_request',
  subevent: 'labeled',
  rewardValue: toPowerOf(50, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'pull_request',
  subevent: 'unlabeled',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'pull_request',
  subevent: 'opened',
  rewardValue: toPowerOf(100, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'pull_request',
  subevent: 'edited',
  rewardValue: toPowerOf(50, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'pull_request',
  subevent: 'closed',
  rewardValue: toPowerOf(100, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'pull_request',
  subevent: 'reopened',
  rewardValue: toPowerOf(15, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'ping',
  subevent: '',
  rewardValue: toPowerOf(2500, decimals),
  reserveValue: toPowerOf(5000, decimals)
},{
  event: 'push',
  subevent: '',
  rewardValue: toPowerOf(250, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'release',
  subevent: 'published',
  rewardValue: toPowerOf(5000, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'repository',
  subevent: 'created',
  rewardValue: toPowerOf(1000, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'repository',
  subevent: 'deleted',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'repository',
  subevent: 'publicized',
  rewardValue: toPowerOf(2500, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'repository',
  subevent: 'privatized',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'status',
  subevent: 'pending',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'status',
  subevent: 'success',
  rewardValue: toPowerOf(500, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'status',
  subevent: 'failure',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'status',
  subevent: 'error',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'team',
  subevent: 'created',
  rewardValue: toPowerOf(1000, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'team',
  subevent: 'deleted',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'team',
  subevent: 'edited',
  rewardValue: toPowerOf(100, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'team',
  subevent: 'added_to_repository',
  rewardValue: toPowerOf(100, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'team',
  subevent: 'removed_from_repository',
  rewardValue: toPowerOf(0, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'team_add',
  subevent: '',
  rewardValue: toPowerOf(1000, decimals),
  reserveValue: toPowerOf(0, decimals)
},{
  event: 'watch',
  subevent: 'started',
  rewardValue: toPowerOf(500, decimals),
  reserveValue: toPowerOf(500, decimals)
}]


function initContract() {
  return new Promise((resolve, reject) => {
    RewardPoints.new(
      decimals
    ).then(function(contract) {
      resolve(contract)
    }).catch(function(error) {
      reject(error)
    })
  })
}
