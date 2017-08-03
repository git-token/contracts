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


  })
});
