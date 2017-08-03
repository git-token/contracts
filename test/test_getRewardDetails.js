var GitToken = artifacts.require("./GitToken.sol");
const { contributorAddress, username, name, organization, symbol, decimals } = require('../gittoken.config')

contract('GitToken', function(accounts) {
  describe("GitToken::getRewardDetails", function() {

    it("Should return reward and reserve values (250 * Math.pow(10, decimals), 15000 * Math.pow(10, decimals)) for `milestone` and `created` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('milestone', 'created');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 250 * Math.pow(10, decimals), "Value did not equal 250 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 15000 * Math.pow(10, decimals), "Value did not equal 15000 * Math.pow(10, decimals)");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (1000 * Math.pow(10, decimals), 15000 * Math.pow(10, decimals)) for `organization` and `members_added` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('organization', 'member_added');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 1000 * Math.pow(10, decimals), "Value did not equal 1000 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 15000 * Math.pow(10, decimals), "Value did not equal 15000 * Math.pow(10, decimals)");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (2500 * Math.pow(10, decimals), 0) for `ping` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('ping', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 2500 * Math.pow(10, decimals), "Value did not equal 2500 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (250 * Math.pow(10, decimals), 0) for `commit_comment` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('commit_comment', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 250 * Math.pow(10, decimals), "Value did not equal 250 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (2500 * Math.pow(10, decimals), 0) for `create` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('create', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 2500 * Math.pow(10, decimals), "Value did not equal 2500 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (0 * Math.pow(10, decimals), 0) for `delete` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('delete', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 0 * Math.pow(10, decimals), "Value did not equal 0 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (5000 * Math.pow(10, decimals), 0) for `deployment` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('deployment', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 5000 * Math.pow(10, decimals), "Value did not equal 5000 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (100 * Math.pow(10, decimals), 0) for `deployment_status` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('deployment_status', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 100 * Math.pow(10, decimals), "Value did not equal 100 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (5000 * Math.pow(10, decimals), 0) for `fork` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('fork', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 5000 * Math.pow(10, decimals), "Value did not equal 5000 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (100 * Math.pow(10, decimals), 0) for `gollum` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('gollum', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 100 * Math.pow(10, decimals), "Value did not equal 100 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (250 * Math.pow(10, decimals), 0) for `installation` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('installation', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 250 * Math.pow(10, decimals), "Value did not equal 250 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (1000 * Math.pow(10, decimals), 0) for `installation_repositories` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('installation_repositories', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 1000 * Math.pow(10, decimals), "Value did not equal 1000 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (250 * Math.pow(10, decimals), 0) for `issue_comment` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('issue_comment', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 250 * Math.pow(10, decimals), "Value did not equal 250 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (500 * Math.pow(10, decimals), 0) for `issues` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('issues', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 500 * Math.pow(10, decimals), "Value did not equal 500 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (100 * Math.pow(10, decimals), 0) for `label` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('label', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 100 * Math.pow(10, decimals), "Value did not equal 100 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (0 * Math.pow(10, decimals), 0) for `marketplace_purchases` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('marketplace_purchases', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 0 * Math.pow(10, decimals), "Value did not equal 0 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (1000 * Math.pow(10, decimals), 0) for `member` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('member', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 1000 * Math.pow(10, decimals), "Value did not equal 1000 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (1000 * Math.pow(10, decimals), 0) for `membership` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('membership', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 1000 * Math.pow(10, decimals), "Value did not equal 1000 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (250 * Math.pow(10, decimals), 0) for `milestone` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('milestone', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 250 * Math.pow(10, decimals), "Value did not equal 250 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (1000 * Math.pow(10, decimals), 0) for `organization` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('organization', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 1000 * Math.pow(10, decimals), "Value did not equal 1000 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (0 * Math.pow(10, decimals), 0) for `org_block` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('org_block', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 0 * Math.pow(10, decimals), "Value did not equal 0 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (500 * Math.pow(10, decimals), 0) for `page_build` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('page_build', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 500 * Math.pow(10, decimals), "Value did not equal 500 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (250 * Math.pow(10, decimals), 0) for `project_card` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('project_card', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 250 * Math.pow(10, decimals), "Value did not equal 250 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (50 * Math.pow(10, decimals), 0) for `project_column` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('project_column', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 50 * Math.pow(10, decimals), "Value did not equal 50 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (1000 * Math.pow(10, decimals), 0) for `project` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('project', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 1000 * Math.pow(10, decimals), "Value did not equal 1000 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (10000 * Math.pow(10, decimals), 0) for `public` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('public', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 10000 * Math.pow(10, decimals), "Value did not equal 10000 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (250 * Math.pow(10, decimals), 0) for `pull_request_review_comment` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('pull_request_review_comment', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 250 * Math.pow(10, decimals), "Value did not equal 250 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (250 * Math.pow(10, decimals), 0) for `pull_request_review` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('pull_request_review', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 250 * Math.pow(10, decimals), "Value did not equal 250 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (2500 * Math.pow(10, decimals), 0) for `pull_request` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('pull_request', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 2500 * Math.pow(10, decimals), "Value did not equal 2500 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (1000 * Math.pow(10, decimals), 0) for `push` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('push', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 1000 * Math.pow(10, decimals), "Value did not equal 1000 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (2500 * Math.pow(10, decimals), 0) for `repository` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('repository', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 2500 * Math.pow(10, decimals), "Value did not equal 2500 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (5000 * Math.pow(10, decimals), 0) for `release` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('release', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 5000 * Math.pow(10, decimals), "Value did not equal 5000 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (200 * Math.pow(10, decimals), 0) for `status` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('status', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 200 * Math.pow(10, decimals), "Value did not equal 200 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (2000 * Math.pow(10, decimals), 0) for `team` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('team', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 2000 * Math.pow(10, decimals), "Value did not equal 2000 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (2000 * Math.pow(10, decimals), 0) for `team_add` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('team_add', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 2000 * Math.pow(10, decimals), "Value did not equal 2000 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

    it("Should return reward and reserve values (100 * Math.pow(10, decimals), 0) for `watch` and `` GitHub web hook event and action", function() {
      return GitToken.new(
        contributorAddress,
        username,
        name,
        organization,
        symbol,
        decimals
      ).then(function(gittoken) {
        return gittoken.getRewardDetails.call('watch', '');
      }).then(function(values){
        assert.equal(values[0].toNumber(), 100 * Math.pow(10, decimals), "Value did not equal 100 * Math.pow(10, decimals)");
        assert.equal(values[1].toNumber(), 0, "Value did not equal 0");
      }).catch(function(error) {
        assert.equal(error, null, error.toString())
      });
    });

  })
});
