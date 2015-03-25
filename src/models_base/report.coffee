module.exports.fields = (sequelize, DataTypes) ->
  ad_network_account_id: {type: DataTypes.INTEGER, allowNull: false}

#request attributes
  start_date: {type: DataTypes.DATE, allowNull: false}
  end_date: {type: DataTypes.DATE, allowNull: false}
  timezone: {type: DataTypes.STRING, allowNull: false}
#day is start_date in yyyy-mm-dd format in selected timezone.
  day: {type: DataTypes.STRING, allowNull: false}

  processing_date: {type: DataTypes.DATE, allowNull: false}
  interval_type: {type: DataTypes.STRING, allowNull: false}
#start_date is a real start date for response from adv Network. In daily reports Adv networks are using different
#timezones. Similar with requested_end_date

  #next fields was temporaritly removed from database request
  #requested_start_date: {type: DataTypes.DATE, allowNull: false}
  #requested_end_date: {type: DataTypes.DATE, allowNull: false}

#real data
  revenue: {type: DataTypes.DECIMAL, allowNull: false}
  currency: {type: DataTypes.STRING, allowNull: false}
  requests: {type: DataTypes.BIGINT}
  impressions: {type: DataTypes.BIGINT}
  clicks: {type: DataTypes.BIGINT}
  ctr: {type: DataTypes.DECIMAL}
  cpc: {type: DataTypes.DECIMAL}
  cpm: {type: DataTypes.DECIMAL}
  fill_rate: {type: DataTypes.DECIMAL}
  json: {type: DataTypes.TEXT}
