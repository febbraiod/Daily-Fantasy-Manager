var Player = React.createClass({
  render: function() {
    return (
      <tr>
        <td>{this.props.player.name}</td>
        <td>{this.props.player.position}</td>
      </tr>
    );
  }
});