require("busted.runner")()

local PublicKey = require("gamechain.publickey")
local PrivateKey = require("gamechain.privatekey")

describe("PrivateKey", function ()
	it("should always create a unique key", function ()
		local a = PrivateKey()
		local b = PrivateKey()
		assert.are_not.equal(a, b)
	end)

	it("should be serializable to string", function ()
		local key = PrivateKey()
		assert.are.equal(PrivateKey(tostring(key)), key)
	end)

	it("should sign and verify data", function ()
		local key = PrivateKey()
		local sig = key:sign("foobar", "fuzzbuzz")
		assert.is_true(key:verify(sig, "foobar", "fuzzbuzz"))
	end)

	it("should still verify signatures after serialization", function ()
		local key = PrivateKey()
		local sig = key:sign("foobar", "fuzzbuzz")

		key = PrivateKey(tostring(key))
		assert.is_true(key:verify(sig, "foobar", "fuzzbuzz"))
	end)

	it("should fail to verify incorrect data", function ()
		local key = PrivateKey()
		local sig = key:sign("foobar", "fuzzbuzz")
		assert.is_false(key:verify(sig, "fuzzbuzz", "foobar"))
	end)

	it("should fail to verify another key's signature", function ()
		local a = PrivateKey()
		local b = PrivateKey()
		local sig = a:sign("foobar", "fuzzbuzz")
		assert.is_false(b:verify(sig, "foobar", "fuzzbuzz"))
	end)
end)

describe("PublicKey", function ()
	it("should be created from a private key", function ()
		local privkey = PrivateKey()
		local pubkey = privkey:public_key()
		assert.are_not.equal(pubkey, privkey)
	end)

	it("should serialize differently than a private key", function ()
		local privkey = PrivateKey()
		local pubkey = privkey:public_key()
		assert.are_not.equal(tostring(pubkey), tostring(privkey))
	end)

	it("should verify private key signatures", function ()
		local privkey = PrivateKey()
		local sig = privkey:sign("foobar", "fuzzbuzz")

		local pubkey = privkey:public_key()
		assert.is_true(pubkey:verify(sig, "foobar", "fuzzbuzz"))
	end)

	it("should still verify private key signatures after serialization", function ()
		local privkey = PrivateKey()
		local sig = privkey:sign("foobar", "fuzzbuzz")

		local pubkey = PublicKey(tostring(privkey:public_key()))
		assert.is_true(pubkey:verify(sig, "foobar", "fuzzbuzz"))
	end)

	it("should fail to verify incorrect data", function ()
		local privkey = PrivateKey()
		local sig = privkey:sign("foobar", "fuzzbuzz")
		
		local pubkey = PublicKey(privkey)
		assert.is_false(pubkey:verify(sig, "fuzzbuzz", "foobar"))
	end)

	it("should fail to verify another key's signature", function ()
		local a = PrivateKey()
		local b = PrivateKey()
		local sig = a:sign("foobar", "fuzzbuzz")

		local pubkey = PublicKey(b)
		assert.is_false(pubkey:verify(sig, "foobar", "fuzzbuzz"))
	end)
end)