describe User do
  it "can have multiple valid tokens" do
    u = create(:user, email: "janus@two-faces.org")

    t1 = u.create_token!
    t2 = u.create_token!

    t1.refresh
    t2.refresh

    expect(t1).to be_valid
    expect(t2).to be_valid
  end
end
