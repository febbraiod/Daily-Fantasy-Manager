var Players = React.createClass({
  getInitialState: function() {
    return {
      players: this.props.data
    };
  },
  getDefaultProps: function() {
    return {
      players: []
    };
  },
  render: function() {
    return(
      <div className='players'>
        <h2 className='title'>
          Players
        </h2>
      <table className='table table-bordered'>
          <thead>
            <tr>
              <th>Name</th>
              <th>Position</th>
            </tr>
          </thead>
          <tbody>
            {this.state.players.map(function(player) {
              return <Player key={player.id} player={player}
                              />
             }.bind(this))}
          </tbody>
        </table>
        </div>
    );
  }
});